# frozen_string_literal: false

class CreateCampaignmanagerPlayers < ActiveRecord::Migration
  def change
    create_table :campaignmanager_players, id: :uuid do |t|
      t.uuid :campaign_id
      t.uuid :affiliation_id

      t.timestamps
    end

    add_index :campaignmanager_players, [:campaign_id, :affiliation_id], :unique => true, :name => 'index_campaignmanager_players_campaign_and_affiliate'
  end
end
