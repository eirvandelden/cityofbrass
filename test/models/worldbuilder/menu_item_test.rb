require 'test_helper'

module Worldbuilder
  class MenuItemTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      menu_item = MenuItem.new
      assert_not menu_item.valid?
      assert_equal [:menu_itemable_type, :item_label], menu_item.errors.keys
    end

  end
end
