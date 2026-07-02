require "test_helper"

module Rulebuilder
  class RuleTest < ActiveSupport::TestCase
    test "resident should have the necessary required validators" do
      rule = ResidentRule.new(name: "ResidentRuleTest")
      assert_not rule.valid?
      assert_equal [ :core_rules, :rule_type, :resident, :resident_id ], rule.errors.attribute_names
    end

    test "stock should have the necessary required validators" do
      rule = StockRule.new(name: "StockRuleTest")
      assert_not rule.valid?
      assert_equal [ :core_rules, :rule_type ], rule.errors.attribute_names
    end

    test "list helpers return comma separated values" do
      rule = rulebuilder_rules(:resident_one)

      assert_equal "hello1, world2", rule.tag_list
      assert_equal "One, Two", rule.category_list
    end

    test "allows long full descriptions" do
      rule = StockRule.new(
        name: "Long Rule",
        core_rules: "pf1e",
        rule_type: "Ability",
        full_description: "x" * 100_000
      )

      assert rule.valid?, rule.errors.full_messages.to_sentence
    end
  end
end
