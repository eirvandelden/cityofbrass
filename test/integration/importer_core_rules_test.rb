require "test_helper"

class ImporterCoreRulesTest < ActiveSupport::TestCase
  test "5th Edition supports imported species backgrounds and class rules" do
    rule_types = CoreRules::Rule.rule_types("dnd5e")

    assert_includes rule_types, "Species"
    assert_includes rule_types, "Backgrounds"
    assert_includes rule_types, "Class"
  end
end
