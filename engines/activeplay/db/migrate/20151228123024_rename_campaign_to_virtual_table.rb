# frozen_string_literal: false

class RenameCampaignToVirtualTable < ActiveRecord::Migration
  def change
    rename_table :activeplay_campaigns, :activeplay_virtual_tables
  end
end
