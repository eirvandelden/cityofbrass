class AddTypeToCampaigns < ActiveRecord::Migration
  def change
    remove_index :campaignmanager_campaigns, [:resident_id, :slug]

    add_column :campaignmanager_campaigns, :type, :string

    add_index :campaignmanager_campaigns, [:id, :type]
    add_index :campaignmanager_campaigns, :resident_id
  end
end
