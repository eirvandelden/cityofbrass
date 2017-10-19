require 'test_helper'

module Storybuilder
  class PageTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      page = Page.new(name: "PageName")
      assert_not page.valid?
      assert_equal [:adventure_id, :privacy], page.errors.keys
    end

  end
end
