# frozen_string_literal: false

class AddCoreRulesToCampaignmanagerCampaign < ActiveRecord::Migration
  def change
    add_column :campaignmanager_campaigns, :core_rules, :string
  end
end
