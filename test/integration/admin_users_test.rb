require "test_helper"

class AdminUsersTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "new user page renders translated labels" do
    with_default_locale(:nl) do
      sign_in admins(:dan)

      get new_user_path

      assert_response :success
      assert_select "h1.header", text: /Nieuwe gebruiker/
      assert_select "a[href=?]", users_path, text: "Terug naar overzicht"
      assert_select "option", text: "Engels"
      assert_select "option", text: "Nederlands"
      assert_select "option", text: "Italiaans"
    end
  end

  private

  def with_default_locale(locale)
    original_locale = I18n.default_locale
    I18n.default_locale = locale
    yield
  ensure
    I18n.default_locale = original_locale
  end
end
