class AddCoreRulesToCampaignmanagerCampaign < ActiveRecord::Migration[4.2]
  def change
    add_column :campaignmanager_campaigns, :core_rules, :string
  end
end
