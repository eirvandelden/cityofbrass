class RemoveResidentIdFromCampaignmanagerPage < ActiveRecord::Migration[4.2]
  def change
    remove_column :campaignmanager_pages, :resident_id, :string
  end
end
