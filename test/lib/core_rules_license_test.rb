require "test_helper"

class CoreRulesLicenseTest < ActiveSupport::TestCase
  test "4th Edition has no license metadata" do
    assert_nil CoreRules.license("dnd4e")
  end
end
