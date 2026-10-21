require "test_helper"
require "jwt"

class JwtEmptyKeyTest < ActiveSupport::TestCase
  test "signing with an empty key is refused" do
    assert_raises(JWT::EncodeError) { JWT.encode({ "sub" => "gm" }, "", "HS256") }
  end

  test "signing with a nil key is refused" do
    assert_raises(JWT::EncodeError) { JWT.encode({ "sub" => "gm" }, nil, "HS256") }
  end

  test "decoding a token forged with an empty key is refused" do
    assert_raises(JWT::DecodeError) { JWT.decode(token_forged_with_empty_key, "", true, algorithm: "HS256") }
  end

  private

  def token_forged_with_empty_key
    parts = [ { "alg" => "HS256", "typ" => "JWT" }, { "sub" => "gm" } ]
    signing_input = parts.map { |part| base64url(part.to_json) }.join(".")
    signature = OpenSSL::HMAC.digest("SHA256", "", signing_input)

    "#{signing_input}.#{base64url(signature)}"
  end

  def base64url(data)
    Base64.urlsafe_encode64(data, padding: false)
  end
end
