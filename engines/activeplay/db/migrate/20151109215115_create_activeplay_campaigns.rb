# frozen_string_literal: false

class CreateActiveplayCampaigns < ActiveRecord::Migration
  def change
    create_table :activeplay_campaigns, id: :uuid do |t|
      t.uuid :campaign_id

      t.timestamps null: false
    end

    add_index :activeplay_campaigns, :campaign_id, :unique => true
  end
end
