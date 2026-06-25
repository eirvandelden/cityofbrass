require "test_helper"

class LocaleSettingsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "account settings render locale choices in the user's locale" do
    user = users(:dan)
    user.update!(locale: "it")

    sign_in user
    get edit_account_path

    assert_response :success
    assert_select "option", text: "Inglese"
    assert_select "option", text: "Olandese"
    assert_select "option", text: "Italiano"
  end

  test "legacy user settings path updates the signed in user's locale" do
    user = users(:dan)

    sign_in user
    get "/users/edit"

    assert_response :success
    assert_select "form[action=?]", "/users"

    patch "/users", params: { user: { email: user.email, locale: "nl" } }

    assert_redirected_to "/users/edit"
    assert_equal "nl", user.reload.locale
  end
end
