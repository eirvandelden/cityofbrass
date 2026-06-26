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

  test "email changes require the signed in user's current password" do
    user = users(:dan)
    email = user.email

    sign_in user
    patch user_settings_path, params: { user: { email: "changed@example.com", locale: user.locale } }

    assert_response :unprocessable_entity
    assert_equal email, user.reload.email
    assert_nil user.unconfirmed_email
  end

  test "password changes require the signed in user's current password" do
    user = users(:dan)

    sign_in user
    patch user_settings_path, params: {
      user: {
        email: user.email,
        locale: user.locale,
        password: "new-password",
        password_confirmation: "new-password"
      }
    }

    assert_response :unprocessable_entity
    assert user.reload.valid_password?("password")
  end

  test "password changes with the signed in user's current password" do
    user = users(:dan)

    sign_in user
    patch user_settings_path, params: {
      user: {
        email: user.email,
        locale: user.locale,
        password: "new-password",
        password_confirmation: "new-password",
        current_password: "password"
      }
    }

    assert_redirected_to "/users/edit"
    assert user.reload.valid_password?("new-password")
  end
end
