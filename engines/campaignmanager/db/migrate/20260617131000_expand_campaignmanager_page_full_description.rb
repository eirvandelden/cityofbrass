class ExpandCampaignmanagerPageFullDescription < ActiveRecord::Migration[6.1]
  def change
    change_column :campaignmanager_pages, :full_description, :text, limit: 16.megabytes - 1
  end
end
