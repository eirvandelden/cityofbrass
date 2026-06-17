require 'test_helper'

module Campaignmanager
  class PageTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      page = Page.new(name: "PageName")
      assert_not page.valid?
      assert_equal [:campaign_id, :privacy], page.errors.keys
    end

    test "game master notes allow long full descriptions" do
      note = GameMasterNote.new(
        campaign: campaignmanager_campaigns(:resident_one),
        name: "Long GM Note",
        privacy: "Private",
        full_description: "x" * 100_000
      )

      assert note.valid?
    end

  end
end
