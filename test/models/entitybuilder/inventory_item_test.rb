require 'test_helper'

module Entitybuilder
  class InventoryItemTest < ActiveSupport::TestCase

    test "resident should have the necessary required validators" do
      inventory_item = InventoryItem.new
      assert_not inventory_item.valid?
      assert_equal [:item_id, :quantity], inventory_item.errors.keys
    end

  end
end
