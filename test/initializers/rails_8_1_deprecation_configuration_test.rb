require "test_helper"

class Rails81DeprecationConfigurationTest < ActiveSupport::TestCase
  test "loads Rails 8.1 framework defaults" do
    assert_equal 8.1, Rails.application.config.loaded_config_version
  end

  test "uses the Rails 7.1 cache serialization format" do
    assert_equal 7.1, ActiveSupport::Cache.format_version
  end

  test "uses the JSON cookie serializer" do
    assert_equal :json, Rails.application.config.action_dispatch.cookies_serializer
  end
end
