require "test_helper"

class Rails71DeprecationConfigurationTest < ActiveSupport::TestCase
  test "uses the Rails 7.1 cache serialization format" do
    assert_equal 7.1, ActiveSupport::Cache.format_version
  end

  test "configures Devise secret key without Rails secrets fallback" do
    assert_equal Rails.application.config.secret_key_base, Devise.secret_key
  end
end
