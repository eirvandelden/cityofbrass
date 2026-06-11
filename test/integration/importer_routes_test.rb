require "test_helper"

class ImporterRoutesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "normal user can open resident import preview form" do
    sign_in users(:dan)

    get "/imports/previews/new"

    assert_response :success
    assert_select "div.row div.medium-10.medium-centered.columns main"
  end

  test "normal user import index uses page structure" do
    sign_in users(:dan)

    get "/imports"

    assert_response :success
    assert_select "div.row div.medium-10.medium-centered.columns main"
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
    assert_select "div.row div.medium-10.medium-centered.columns main"
  end

  test "admin stock import index uses page structure" do
    sign_in admins(:dan)

    get "/admin/imports"

    assert_response :success
    assert_select "div.row div.medium-10.medium-centered.columns main"
  end
end
