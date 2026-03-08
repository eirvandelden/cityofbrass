class AddDistrictIdAndAdventureIdToCampaignmanagerCampaigns < ActiveRecord::Migration[4.2]
  def change
    add_column :campaignmanager_campaigns, :district_id, :string
    add_column :campaignmanager_campaigns, :adventure_id, :string

    add_index :campaignmanager_campaigns, :district_id
    add_index :campaignmanager_campaigns, :adventure_id
  end
end
