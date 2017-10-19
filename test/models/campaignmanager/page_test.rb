require 'test_helper'

module Campaignmanager
  class PageTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      page = Page.new(name: "PageName")
      assert_not page.valid?
      assert_equal [:campaign_id, :privacy], page.errors.keys
    end

  end
end
