require "test_helper"

class UserSignInTest < ActionDispatch::IntegrationTest
  test "user signs in with the right password" do
    post user_session_path, params: { user: { email: users(:dan).email, password: "password" } }

    assert_response :redirect
    follow_redirect!

    assert_not_equal new_user_session_path, path
  end

  test "user with a wrong password is turned away" do
    post user_session_path, params: { user: { email: users(:dan).email, password: "wrong" } }

    assert_response :success
    assert_select "form[action=?]", user_session_path
    get root_path

    assert_select "a[href=?]", destroy_user_session_path, count: 0
  end
end
