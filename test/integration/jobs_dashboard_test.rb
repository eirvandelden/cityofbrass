require "test_helper"

class JobsDashboardTest < ActionDispatch::IntegrationTest
  test "signed out visitor is redirected to the admin login" do
    get "/jobs"

    assert_redirected_to "/admins/login"
  end

  test "admin can open the jobs dashboard" do
    sign_in admins(:dan)

    get "/jobs"

    assert_response :success
  end

  test "user cannot open the jobs dashboard" do
    sign_in users(:dan)

    get "/jobs"

    assert_redirected_to "/admins/login"
  end
end
