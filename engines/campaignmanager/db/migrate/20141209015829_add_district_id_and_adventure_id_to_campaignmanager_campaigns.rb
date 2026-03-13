class AddDistrictIdAndAdventureIdToCampaignmanagerCampaigns < ActiveRecord::Migration
  def change
    add_column :campaignmanager_campaigns, :district_id, :uuid
    add_column :campaignmanager_campaigns, :adventure_id, :uuid

    add_index :campaignmanager_campaigns, :district_id
    add_index :campaignmanager_campaigns, :adventure_id
  end
end
