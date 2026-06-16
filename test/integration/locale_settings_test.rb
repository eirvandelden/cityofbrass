require "test_helper"

class LocaleSettingsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "account settings render locale choices in the user's locale" do
    user = users(:dan)
    user.update!(locale: "it")

    sign_in user
    get edit_user_registration_path

    assert_response :success
    assert_select "option", text: "Inglese"
    assert_select "option", text: "Olandese"
    assert_select "option", text: "Italiano"
  end
end
