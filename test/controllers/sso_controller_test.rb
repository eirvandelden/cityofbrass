require "test_helper"
require "single_sign_on"

class SsoControllerTest < ActionDispatch::IntegrationTest
  test "redirect carries the user's email and resident name" do
    with_sso_env do
      sign_in users(:dan)
      get sso_symposium_path, params: signed_request
    end
    carried = SingleSignOn.parse(URI(response.location).query, "test-secret")

    assert_equal users(:dan).email, carried.email
    assert_equal residents(:razune).name, carried.name
  end

  private
    def signed_request
      payload = Base64.encode64("nonce=abc123")
      { sso: payload, sig: SingleSignOn.new.tap { |sso| sso.sso_secret = "test-secret" }.sign(payload) }
    end

    def with_sso_env
      original = ENV.values_at("SYMPOSIUM_SSO_SECRET", "SYMPOSIUM_SSO_URL")
      ENV["SYMPOSIUM_SSO_SECRET"] = "test-secret"
      ENV["SYMPOSIUM_SSO_URL"] = "https://forum.example.com/session/sso_login"
      yield
    ensure
      ENV["SYMPOSIUM_SSO_SECRET"], ENV["SYMPOSIUM_SSO_URL"] = original
    end
end
