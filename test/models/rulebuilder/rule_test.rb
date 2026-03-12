require 'test_helper'

module Rulebuilder
  class RuleTest < ActiveSupport::TestCase
    test "resident should have the necessary required validators" do
      rule = ResidentRule.new(name: "ResidentRuleTest")
      assert_not rule.valid?
      assert_equal [:core_rules, :rule_type, :resident_id], rule.errors.keys
    end

    test "stock should have the necessary required validators" do
      rule = StockRule.new(name: "StockRuleTest")
      assert_not rule.valid?
      assert_equal [:core_rules, :rule_type], rule.errors.keys
    end

    test "proprietary should have the necessary required validators" do
      rule = ProprietaryRule.new(name: "ProprietaryRuleTest")
      assert_not rule.valid?
      assert_equal [:core_rules, :rule_type], rule.errors.keys
    end

    test "list helpers return comma separated values" do
      rule = rulebuilder_rules(:resident_one)

      assert_equal "hello1, world2", rule.tag_list
      assert_equal "One, Two", rule.category_list
    end
  end
end
