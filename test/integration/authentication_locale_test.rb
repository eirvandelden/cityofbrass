require "test_helper"

class AuthenticationLocaleTest < ActionDispatch::IntegrationTest
  test "visitor with dutch accept-language sees dutch sign in page" do
    get new_user_session_path, headers: { "Accept-Language" => "nl" }

    assert_select "label.flat", text: "Inloggen"
  end

  test "dutch user sees dutch signed in notice" do
    users(:dan).update!(locale: "nl")
    post user_session_path, params: { user: { email: users(:dan).email, password: "password" } }

    assert_equal "Je bent succesvol ingelogd.", flash[:notice]
  end

  test "accept-language picks the highest weighted available locale" do
    get new_user_session_path, headers: { "Accept-Language" => "de;q=0.9, it;q=0.8, nl;q=0.7" }

    assert_select "label.flat", text: "Accedi"
  end

  test "accept-language region tag maps to its language" do
    get new_user_session_path, headers: { "Accept-Language" => "nl-NL,nl;q=0.9" }

    assert_select "label.flat", text: "Inloggen"
  end

  test "accept-language skips a language marked not acceptable" do
    get new_user_session_path, headers: { "Accept-Language" => "nl;q=0, de" }

    assert_select "label.flat", text: "Login"
  end

  test "accept-language allows spaces around parameters" do
    get new_user_session_path, headers: { "Accept-Language" => "de, nl ; q=0.8" }

    assert_select "label.flat", text: "Inloggen"
  end

  test "falls back to default for an unknown language" do
    get new_user_session_path, headers: { "Accept-Language" => "de-DE,fr;q=0.8" }

    assert_select "label.flat", text: "Login"
  end

  test "signed-in user's locale wins over accept-language" do
    users(:dan).update!(locale: "it")
    sign_in users(:dan)
    get edit_account_path, headers: { "Accept-Language" => "nl" }

    assert_select "option", text: "Olandese"
  end
end
