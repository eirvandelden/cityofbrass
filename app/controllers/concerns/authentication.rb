# Cookie-backed sign-in for User and Admin. Both can be signed in at once.
module Authentication
  extend ActiveSupport::Concern

  COOKIE_NAMES = { "User" => :session_id, "Admin" => :admin_session_id }.freeze
  COOKIE_OPTIONS = { expires: 1.year, httponly: true, same_site: :lax }.freeze

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
    request_authentication(main_app.new_user_session_path) unless user_signed_in?
  end

  def authenticate_admin!
    request_authentication(main_app.new_admin_session_path) unless admin_signed_in?
  end

  def start_new_session_for(account)
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
      session_record = find_session(type)
      write_cookie(type, session_record) if session_record
      session_record
    end

    def find_session(type)
      id = cookies.signed[COOKIE_NAMES.fetch(type)]
      Session.find_by(id: id, authenticatable_type: type) if id.present?
    end

    def write_cookie(type, session_record)
      cookies.signed[COOKIE_NAMES.fetch(type)] = COOKIE_OPTIONS.merge(value: session_record.id)
    end

    def request_authentication(login_path)
      return head(:unauthorized) unless request.format.html?

      session[:return_to_after_authenticating] = request.url if request.get?
      redirect_to login_path, alert: t("authentication.unauthenticated")
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || main_app.root_url
    end
end
