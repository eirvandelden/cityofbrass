require "test_helper"

class UserUnlocksTest < ActionDispatch::IntegrationTest
  test "renders unlock instructions form" do
    get new_user_unlock_path

    assert_response :success
    assert_select "form[action=?]", user_unlock_path
    assert_select "[name='user[email]']"
  end
end
