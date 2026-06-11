require "test_helper"

class SidekiqWebTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "admin can open sidekiq web" do
    sign_in admins(:dan)

    get "/sidekiq"

    assert_response :success
  end

  test "user cannot open sidekiq web" do
    sign_in users(:dan)

    get "/sidekiq"

    assert_response :redirect
  end
end
