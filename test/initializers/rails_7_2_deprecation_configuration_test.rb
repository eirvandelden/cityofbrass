require "test_helper"

class Rails72DeprecationConfigurationTest < ActiveSupport::TestCase
  test "loads Rails 7.2 framework defaults" do
    assert_equal 7.2, Rails.application.config.loaded_config_version
  end

  test "uses the Rails 7.1 cache serialization format" do
    assert_equal 7.1, ActiveSupport::Cache.format_version
  end

  test "configures Devise secret key without Rails secrets fallback" do
    assert_equal Rails.application.config.secret_key_base, Devise.secret_key
  end

  test "uses the JSON cookie serializer" do
    assert_equal :json, Rails.application.config.action_dispatch.cookies_serializer
  end
end
