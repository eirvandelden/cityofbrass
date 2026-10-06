# Password sign-in, lockout, sign-in tracking and reset tokens shared by User and Admin.
module Authenticatable
  extend ActiveSupport::Concern

  MAXIMUM_ATTEMPTS = 20
  UNLOCK_IN = 1.hour

  class Locked < StandardError; end

  included do
    has_secure_password reset_token: { expires_in: 6.hours }
    has_many :sessions, as: :authenticatable, dependent: :destroy

    normalizes :email, with: ->(email) { email.strip.downcase }

    validates :password, length: { minimum: 8 }, allow_nil: true
  end

  class_methods do
    def authenticate_by_credentials(email:, password:)
      find_by(email: email)&.authenticate_unless_locked(password)
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

  def register_failed_attempt
    attempts = failed_attempts + 1
    update_columns(failed_attempts: attempts, locked_at: (Time.current if attempts >= MAXIMUM_ATTEMPTS))
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
