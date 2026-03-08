require "test_helper"

class SupportTest < ActiveSupport::TestCase
  test "loads the engine" do
    assert_kind_of Module, Support
    assert_operator Support::Engine, :<, Rails::Engine
  end
end
