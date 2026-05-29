require "test_helper"

class ImporterCoreRulesTest < ActiveSupport::TestCase
  test "5th Edition supports imported race background and class rules" do
    rule_types = CoreRules::Rule.rule_types("5th Edition")

    assert_includes rule_types, "Race"
    assert_includes rule_types, "Background"
    assert_includes rule_types, "Class"
  end
end
