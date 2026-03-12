class RenameCampaignToVirtualTable < ActiveRecord::Migration[4.2]
  def change
    rename_table :activeplay_campaigns, :activeplay_virtual_tables
  end
end
