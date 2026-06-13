require 'test_helper'

module Rulebuilder
  class ItemTest < ActiveSupport::TestCase
    test "resident should have the necessary required validators" do
      item = ResidentItem.new(name: "ResidentItemTest")
      assert_not item.valid?
      assert_equal [:core_rules, :resident_id], item.errors.keys
    end

    test "stock should have the necessary required validators" do
      item = StockItem.new(name: "StockItemTest")
      assert_not item.valid?
      assert_equal [:core_rules], item.errors.keys
    end

    test "tag_list returns a comma separated list" do
      assert_equal "hello1, world2", rulebuilder_items(:resident_one).tag_list
    end
  end
end
