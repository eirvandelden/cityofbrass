# frozen_string_literal: false

require 'test_helper'

module Campaignmanager
  class CampaignTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      campaign = Campaign.new(name: "CampaignTest")
      assert_not campaign.valid?
      assert_equal [:resident_id, :privacy], campaign.errors.keys
    end

  end
end
