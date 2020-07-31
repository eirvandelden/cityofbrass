# frozen_string_literal: false

class FixCampaignManagerPageIndexes < ActiveRecord::Migration
  def change
    remove_index :campaignmanager_pages, [:campaign_id, :type, :slug]
    add_index :campaignmanager_pages, :campaign_id
    add_index :campaignmanager_pages, :parent_id
  end
end
