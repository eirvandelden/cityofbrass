require 'test_helper'

module Entitybuilder
  class LinkedRuleTest < ActiveSupport::TestCase

    test "resident should have the necessary required validators" do
      linked_rule = LinkedRule.new
      assert_not linked_rule.valid?
      assert_equal [:entity, :rule], linked_rule.errors.attribute_names
    end

  end
end
