require "test_helper"

class JobsDashboardTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "admin can open the jobs dashboard" do
    sign_in admins(:dan)

    get "/jobs"

    assert_response :success
  end

  test "user cannot open the jobs dashboard" do
    sign_in users(:dan)

    get "/jobs"

    assert_response :redirect
  end
end
