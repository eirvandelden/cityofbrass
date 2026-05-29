require "test_helper"

class ImporterNavigationTest < ActionView::TestCase
  include Devise::Test::ControllerHelpers

  test "admin navigation links to stock imports" do
    render template: "layouts/navigation/_admin"

    assert_select "a[href='/admin/imports']", text: /Stock Imports/
  end

  test "stock navigation does not link to stock imports" do
    render template: "layouts/navigation/_stock"

    assert_select "a[href='/admin/imports']", count: 0
  end
end
