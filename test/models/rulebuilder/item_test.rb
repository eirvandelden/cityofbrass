# frozen_string_literal: false

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

    test "proprietary should have the necessary required validators" do
      item = ProprietaryItem.new(name: "ProprietaryItemTest")
      assert_not item.valid?
      assert_equal [:core_rules], item.errors.keys
    end

  end
end
