require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "user with an existing password signs in" do
    post user_session_path, params: { user: { email: users(:dan).email, password: "password" } }

    assert_redirected_to root_url
    follow_redirect!
    follow_redirect!

    assert_response :success
  end

  test "admin signs in and reaches the admin pages" do
    post admin_session_path, params: { admin: { email: admins(:dan).email, password: "password" } }

    assert_redirected_to root_url
    get admin_importer_imports_path

    assert_response :success
  end

  test "wrong password shows invalid email or password" do
    post user_session_path, params: { user: { email: users(:dan).email, password: "wrong" } }

    assert_response :unprocessable_entity
    assert_select "label.error", text: "Invalid email or password."
    get residents_path

    assert_redirected_to new_user_session_path
  end

  test "signing out ends the session" do
    sign_in users(:dan)
    get residents_path

    assert_response :success
    delete destroy_user_session_path
    get residents_path

    assert_redirected_to new_user_session_path
  end

  test "sign in returns to the requested page" do
    get edit_account_path

    assert_redirected_to new_user_session_path
    post user_session_path, params: { user: { email: users(:dan).email, password: "password" } }

    assert_redirected_to edit_account_url
  end

  test "user without confirmation signs in" do
    post user_session_path, params: { user: { email: users(:dan).email, password: "password" } }

    assert_redirected_to root_url
    assert_predicate users(:dan).sessions, :exists?
  end

  test "session cookie is persistent for a year" do
    post user_session_path, params: { user: { email: users(:dan).email, password: "password" } }

    cookie = Array(response.headers["Set-Cookie"]).join("\n")
    expires = Time.httpdate(cookie[/session_id=[^\n]*?expires=([^;\n]+)/i, 1])

    assert_in_delta 1.year.from_now.to_f, expires.to_f, 1.day.to_f
  end

  test "devise remember cookie does not sign in" do
    cookies[:remember_user_token] = "legacy-token"
    cookies[:_cityofbrass_session] = "legacy-session"
    get residents_path

    assert_redirected_to new_user_session_path
  end

  test "user and admin are signed in together" do
    sign_in users(:dan)
    sign_in admins(:dan)
    get residents_path

    assert_response :success
    get admin_importer_imports_path

    assert_response :success
    delete destroy_admin_session_path
    get residents_path

    assert_response :success
  end

  test "email is stripped and downcased" do
    post user_session_path, params: { user: { email: "  DANIEL@EmbersDS.com ", password: "password" } }

    assert_redirected_to root_url
  end

  test "sign in records ip and user agent" do
    post user_session_path, params: { user: { email: users(:dan).email, password: "password" } },
                            headers: { "User-Agent" => "TestBrowser/1.0", "REMOTE_ADDR" => "203.0.113.9" }
    session_record = users(:dan).sessions.last

    assert_equal "203.0.113.9", session_record.ip_address
    assert_equal "TestBrowser/1.0", session_record.user_agent
  end

  test "sign in updates tracking columns" do
    user = users(:dan)
    post user_session_path, params: { user: { email: user.email, password: "password" } },
                            headers: { "REMOTE_ADDR" => "203.0.113.9" }
    user.reload

    assert_equal 1, user.sign_in_count
    assert_equal "203.0.113.9", user.current_sign_in_ip
    assert_in_delta Time.current, user.current_sign_in_at, 5.seconds
    post user_session_path, params: { user: { email: user.email, password: "password" } },
                            headers: { "REMOTE_ADDR" => "203.0.113.10" }
    user.reload

    assert_equal 2, user.sign_in_count
    assert_equal "203.0.113.9", user.last_sign_in_ip
    assert_equal "203.0.113.10", user.current_sign_in_ip
  end

  test "inactive user is redirected by check_user_status" do
    sign_in users(:brittany)
    get residents_path

    assert_redirected_to root_path
  end

  test "authenticate_user! answers 401 for a js request" do
    get residents_path(format: :json)

    assert_response :unauthorized
  end
end
