# Cookie-backed sign-in for User and Admin. Both can be signed in at once.
module Authentication
  extend ActiveSupport::Concern

  COOKIE_NAMES = { "User" => :session_id, "Admin" => :admin_session_id }.freeze
  COOKIE_OPTIONS = { expires: 1.year, httponly: true, same_site: :lax }.freeze
  RETURN_TO_KEYS = { "User" => :user_return_to, "Admin" => :admin_return_to }.freeze

  included do
    helper_method :current_user, :current_admin, :user_signed_in?, :admin_signed_in?
  end

  def current_user
    Current.user_session ||= resume_session("User")
    Current.user_session&.authenticatable
  end

  def current_admin
    Current.admin_session ||= resume_session("Admin")
    Current.admin_session&.authenticatable
  end

  def user_signed_in?
    current_user.present?
  end

  def admin_signed_in?
    current_admin.present?
  end

  def authenticate_user!
    request_authentication("User", main_app.new_user_session_path) unless user_signed_in?
  end

  def authenticate_admin!
    request_authentication("Admin", main_app.new_admin_session_path) unless admin_signed_in?
  end

  # Starts from a fresh Rails session (new id and CSRF token), so a planted session cannot be reused.
  def start_new_session_for(account)
    reset_session_keeping_return_to(except: account.class.name)
    session_record = account.start_session(ip_address: request.remote_ip, user_agent: request.user_agent)
    write_cookie(account.class.name, session_record)
    session_record
  end

  def terminate_session(type)
    resume_session(type)&.destroy
    cookies.delete(COOKIE_NAMES.fetch(type))
    Current.reset
  end

  private
    def resume_session(type)
      id = cookies.signed[COOKIE_NAMES.fetch(type)]
      return if id.blank?

      session_record = Session.find_by(id: id, authenticatable_type: type)
      session_record ? write_cookie(type, session_record) : cookies.delete(COOKIE_NAMES.fetch(type))
      session_record
    end

    def write_cookie(type, session_record)
      cookies.signed[COOKIE_NAMES.fetch(type)] = COOKIE_OPTIONS.merge(value: session_record.id)
    end

    # Keeps the other scope's pending return-to address; this scope's is used or obsolete after sign-in.
    def reset_session_keeping_return_to(except:)
      return_to = RETURN_TO_KEYS.except(except).values.index_with { |key| session[key] }.compact
      reset_session
      return_to.each { |key, url| session[key] = url }
    end

    def request_authentication(type, login_path)
      return head(:unauthorized) unless request.format.html?

      session[RETURN_TO_KEYS.fetch(type)] = request.url if request.get? || request.head?
      redirect_to login_path, alert: t("authentication.unauthenticated")
    end

    def after_authentication_url(account)
      session.delete(RETURN_TO_KEYS.fetch(account.class.name)) || main_app.root_url
    end
end
