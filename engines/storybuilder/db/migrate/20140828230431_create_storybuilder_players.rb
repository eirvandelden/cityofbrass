# frozen_string_literal: false

class CreateStorybuilderPlayers < ActiveRecord::Migration
  def change
    create_table :storybuilder_players, id: :uuid do |t|
      t.uuid :campaign_id
      t.uuid :affiliation_id

      t.timestamps
    end

    add_index :storybuilder_players, [:campaign_id, :affiliation_id], :unique => true, :name => 'index_storybuilder_players_campaign_and_affiliate'
  end
end
