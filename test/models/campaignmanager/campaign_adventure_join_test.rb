require "test_helper"

module Campaignmanager
  class CampaignAdventureJoinTest < ActiveSupport::TestCase
    test "campaign_adventure_join is valid with campaign, adventure, and active flag" do
      join = campaignmanager_campaign_adventure_joins(:resident_two_active)
      assert join.valid?
    end

    test "campaign returns active adventure" do
      campaign = campaignmanager_campaigns(:resident_two)
      assert_equal storybuilder_adventures(:resident_two), campaign.active_adventure
    end

    test "campaign returns all linked adventures" do
      campaign = campaignmanager_campaigns(:resident_two)
      assert_includes campaign.adventures, storybuilder_adventures(:resident_two)
      assert_includes campaign.adventures, storybuilder_adventures(:resident_one)
    end

    test "duplicate adventure on the same campaign is invalid" do
      existing = campaignmanager_campaign_adventure_joins(:resident_two_active)
      duplicate = CampaignAdventureJoin.new(
        campaign_id: existing.campaign_id,
        adventure_id: existing.adventure_id,
        active: false
      )
      assert_not duplicate.valid?
      assert duplicate.errors[:adventure_id].any?
    end

    test "active_adventure_id= setter flips active flag" do
      campaign = campaignmanager_campaigns(:resident_two)
      inactive_adventure = storybuilder_adventures(:resident_one)

      # Ensure resident_two is currently active
      assert_equal storybuilder_adventures(:resident_two), campaign.active_adventure

      campaign.active_adventure_id = inactive_adventure.id

      # Reload campaign to verify DB state
      campaign.reload
      assert_equal inactive_adventure, campaign.active_adventure

      # The previously active one should now be inactive
      assert_not campaign.campaign_adventure_joins.find_by(adventure_id: storybuilder_adventures(:resident_two).id).active
    end
  end
end
