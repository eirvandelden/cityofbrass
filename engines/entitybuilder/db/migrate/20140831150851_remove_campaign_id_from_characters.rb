class RemoveCampaignIdFromCharacters < ActiveRecord::Migration
  def change
    remove_column :entitybuilder_characters, :campaign_id, :uuid
  end
end
