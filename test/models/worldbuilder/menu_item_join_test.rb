require 'test_helper'

module Worldbuilder
  class MenuItemJoinTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      menu_item_join = MenuItemJoin.new
      assert_not menu_item_join.valid?
      assert_equal [:menu_item_joinable_type], menu_item_join.errors.keys
    end

  end
end
