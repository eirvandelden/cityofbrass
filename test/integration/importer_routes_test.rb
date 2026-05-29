require "test_helper"

class ImporterRoutesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "normal user can open resident import preview form" do
    sign_in users(:dan)

    get "/imports/previews/new"

    assert_response :success
  end

  test "normal user cannot open admin stock import preview form" do
    sign_in users(:dan)

    get "/admin/imports/previews/new"

    assert_response :forbidden
  end

  test "admin can open admin stock import preview form" do
    sign_in admins(:dan)

    get "/admin/imports/previews/new"

    assert_response :success
  end
end
