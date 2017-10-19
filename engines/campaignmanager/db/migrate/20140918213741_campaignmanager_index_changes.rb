class CampaignmanagerIndexChanges < ActiveRecord::Migration
  def change
    remove_index :campaignmanager_campaigns, :privacy
    remove_index :campaignmanager_pages, [:type, :privacy]
    add_index :campaignmanager_pages, :resident_id
  end
end
