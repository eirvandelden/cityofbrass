# frozen_string_literal: false

module Campaignmanager
  module CampaignsHelper

    def cm_new_activeplay_virtual_table(campaign)

      ActiveRecord::Base.transaction do
        activeplay_virtual_table = Activeplay::VirtualTable.new
        activeplay_virtual_table.campaign_id = campaign.id
        activeplay_virtual_table.save(:validate => true)
      end

    end

  end
end
