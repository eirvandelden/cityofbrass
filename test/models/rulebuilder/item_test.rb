require 'test_helper'

module Rulebuilder
  class ItemTest < ActiveSupport::TestCase
    test "resident should have the necessary required validators" do
      item = ResidentItem.new(name: "ResidentItemTest")
      assert_not item.valid?
      assert_equal [:core_rules, :resident, :resident_id], item.errors.attribute_names
    end

    test "stock should have the necessary required validators" do
      item = StockItem.new(name: "StockItemTest")
      assert_not item.valid?
      assert_equal [:core_rules], item.errors.attribute_names
    end

    test "tag_list returns a comma separated list" do
      assert_equal "hello1, world2", rulebuilder_items(:resident_one).tag_list
    end

    test "privacy defaults to Private" do
      item = Rulebuilder::ResidentItem.new
      assert_equal 'Private', item.privacy
    end

    test "can_show? returns true for Public with nil user" do
      item = rulebuilder_items(:resident_one)
      item.privacy = 'Public'
      assert item.can_show?(nil, false, item.type)
    end

    test "can_show? returns false for Private with nil user" do
      item = rulebuilder_items(:resident_one)
      item.privacy = 'Private'
      assert_not item.can_show?(nil, false, item.type)
    end

    test "invalid privacy adds symbolic error" do
      item = Rulebuilder::ResidentItem.new(name: "ResidentItemTest", core_rules: "pf1e", privacy: "Invalid")
      item.valid?
      assert_equal :invalid_privacy, item.errors.details[:privacy].first[:error]
      assert_equal "is not valid.", item.errors[:privacy].first
    end
  end
end
