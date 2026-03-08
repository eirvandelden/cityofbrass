class RemoveTypeFromCampaign < ActiveRecord::Migration[4.2]
  def change
    remove_index :campaignmanager_campaigns, column: [ :id, :type ]
    remove_column :campaignmanager_campaigns, :type, :string
  end
end
