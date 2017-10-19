class RemoveResidentIdFromCampaignmanagerPage < ActiveRecord::Migration
  def change
    remove_column :campaignmanager_pages, :resident_id, :uuid
  end
end
