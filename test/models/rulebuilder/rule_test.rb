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

  end
end
