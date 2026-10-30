# Devise-shaped sign_in / sign_out for integration and controller tests.
module SessionTestHelper
  COOKIE_NAMES = { "User" => :session_id, "Admin" => :admin_session_id }.freeze

  def sign_in(account)
    session_record = account.sessions.create!(ip_address: "127.0.0.1", user_agent: "Rails Testing")
    write_session_cookie(COOKIE_NAMES.fetch(account.class.name), session_record.id)
  end

  def sign_out(account_or_scope)
    type = account_or_scope.respond_to?(:sessions) ? account_or_scope.class.name : account_or_scope.to_s.classify
    cookies.delete(COOKIE_NAMES.fetch(type).to_s)
  end

  private
    def write_session_cookie(name, value)
      if respond_to?(:integration_session)
        jar = ActionDispatch::TestRequest.create.cookie_jar
        jar.signed[name] = value
        cookies[name] = jar[name]
      else
        cookies.signed[name] = value
      end
    end
end
