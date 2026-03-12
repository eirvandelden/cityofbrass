class RemoveCampaignIdFromCharacters < ActiveRecord::Migration[4.2]
  def change
    remove_column :entitybuilder_characters, :campaign_id, :string
  end
end
