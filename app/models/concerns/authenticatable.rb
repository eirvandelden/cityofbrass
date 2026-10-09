# Password sign-in, lockout, sign-in tracking and reset tokens shared by User and Admin.
module Authenticatable
  extend ActiveSupport::Concern

  MAXIMUM_ATTEMPTS = 20
  UNLOCK_IN = 1.hour

  FAILED_ATTEMPT_SQL = "failed_attempts = failed_attempts + 1, " \
                       "locked_at = CASE WHEN failed_attempts + 1 >= ? THEN ? ELSE locked_at END".freeze

  class Locked < StandardError; end

  included do
    has_secure_password reset_token: { expires_in: 6.hours }
    has_many :sessions, as: :authenticatable, dependent: :destroy

    normalizes :email, with: ->(email) { email.strip.downcase }

    validates :password, length: { minimum: 8 }, allow_nil: true

    after_update :end_other_sessions_after_password_change
  end

  class_methods do
    def authenticate_by_credentials(email:, password:)
      account = find_by(email: email)
      return account.authenticate_unless_locked(password) if account

      new(password: password) # Hash anyway, so an unknown email costs the same time as a known one.
      nil
    end
  end

  def authenticate_unless_locked(password)
    unlock if lock_expired?
    raise Locked if locked?

    authenticate(password) || register_failed_attempt
  end

  def locked?
    locked_at.present?
  end

  def unlock
    update_columns(failed_attempts: 0, locked_at: nil)
  end

  # Counts in SQL so parallel wrong guesses on stale copies all count.
  def register_failed_attempt
    self.class.where(id: id).update_all([ FAILED_ATTEMPT_SQL, MAXIMUM_ATTEMPTS, Time.current ])
    nil
  end

  def start_session(ip_address:, user_agent:)
    transaction do
      update_columns(failed_attempts: 0, **tracking_columns(ip_address))
      sessions.create!(ip_address: ip_address, user_agent: user_agent)
    end
  end

  def reset_password(password:, password_confirmation:)
    update(password: password, password_confirmation: password_confirmation).tap { |saved| unlock if saved }
  end

  private
    def end_other_sessions_after_password_change
      return unless saved_change_to_password_digest?

      sessions.where.not(id: Current.session_ids).destroy_all
    end

    def lock_expired?
      locked? && locked_at <= UNLOCK_IN.ago
    end

    def tracking_columns(ip_address)
      now = Time.current
      { sign_in_count: sign_in_count + 1,
        last_sign_in_at: current_sign_in_at, last_sign_in_ip: current_sign_in_ip,
        current_sign_in_at: now, current_sign_in_ip: ip_address }
    end
end
