require "test_helper"

class SessionSecurityTest < ActionDispatch::IntegrationTest
  test "changing the password in account settings keeps this session and ends the others" do
    user = users(:dan)
    other = user.sessions.create!(ip_address: "203.0.113.9", user_agent: "Other device")
    sign_in user

    patch user_settings_path, params: { user: { email: user.email, locale: user.locale, password: "new-password",
                                                password_confirmation: "new-password", current_password: "password" } }

    assert_redirected_to "/users/edit"
    assert_not Session.exists?(other.id)
    get residents_path

    assert_response :success
  end

  test "resetting the password ends every earlier session" do
    user = users(:dan)
    earlier = user.sessions.create!(ip_address: "203.0.113.9", user_agent: "Other device")

    put user_password_path(user.password_reset_token),
        params: { user: { password: "brand-new-pass", password_confirmation: "brand-new-pass" } }

    assert_redirected_to root_path
    assert_not Session.exists?(earlier.id)
  end

  test "signing in starts a fresh rails session" do
    get residents_path # stores the return-to address, so the session is persisted
    session_id_before = session.id.to_s

    post user_session_path, params: { user: { email: users(:dan).email, password: "password" } }

    assert_not_equal session_id_before, session.id.to_s
  end

  test "an admin sign-in does not follow a return-to address stored for a user page" do
    get residents_path

    assert_redirected_to new_user_session_path

    post admin_session_path, params: { admin: { email: admins(:dan).email, password: "password" } }

    assert_redirected_to root_url
  end

  test "a user sign-in follows the return-to address stored for a user page" do
    get residents_path
    post user_session_path, params: { user: { email: users(:dan).email, password: "password" } }

    assert_redirected_to residents_url
  end

  test "a cookie for a deleted session is cleared" do
    user = users(:dan)
    sign_in user
    user.sessions.destroy_all

    get root_path

    assert_predicate cookies["session_id"], :blank?
  end

  test "resetting the password in a signed-in browser ends that browser's earlier session" do
    user = users(:dan)
    post user_session_path, params: { user: { email: user.email, password: "password" } }
    earlier = user.sessions.sole

    put user_password_path(user.password_reset_token),
        params: { user: { password: "brand-new-pass", password_confirmation: "brand-new-pass" } }

    assert_not Session.exists?(earlier.id)
    assert_equal 1, user.sessions.count
  end

  test "an admin sign-in keeps a pending user return-to address" do
    get residents_path
    post admin_session_path, params: { admin: { email: admins(:dan).email, password: "password" } }
    post user_session_path, params: { user: { email: users(:dan).email, password: "password" } }

    assert_redirected_to residents_url
  end
end
