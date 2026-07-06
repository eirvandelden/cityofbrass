require "test_helper"
require Rails.root.join("lib/assume_local_https_proxy")

class AssumeLocalHttpsProxyTest < ActiveSupport::TestCase
  test "treats matching HTTPS localhost origins as HTTPS requests" do
    response = middleware.call(
      Rack::MockRequest.env_for(
        "http://cityofbrass.localhost/campaigns/123/pages",
        "HTTP_ORIGIN" => "https://cityofbrass.localhost"
      )
    )

    assert_equal "https://cityofbrass.localhost", response.last.first
  end

  test "keeps plain HTTP localhost origins unchanged" do
    response = middleware.call(
      Rack::MockRequest.env_for(
        "http://localhost:3000/campaigns/123/pages",
        "HTTP_ORIGIN" => "http://localhost:3000"
      )
    )

    assert_equal "http://localhost:3000", response.last.first
  end

  test "keeps different HTTPS origins unchanged" do
    response = middleware.call(
      Rack::MockRequest.env_for(
        "http://cityofbrass.localhost/campaigns/123/pages",
        "HTTP_ORIGIN" => "https://other.localhost"
      )
    )

    assert_equal "http://cityofbrass.localhost", response.last.first
  end

  private
    def middleware
      AssumeLocalHttpsProxy.new(base_url_app)
    end

    def base_url_app
      lambda do |env|
        request = ActionDispatch::Request.new(env)
        [ 200, {}, [ request.base_url ] ]
      end
    end
end
