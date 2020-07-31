# frozen_string_literal: false

class CreateCampaignmanagerPages < ActiveRecord::Migration
  def change
    create_table :campaignmanager_pages, id: :uuid do |t|
      t.string :type, :null => false
      t.uuid :resident_id
      t.uuid :campaign_id
      t.uuid :parent_id
      t.string :name
      t.string :slug
      t.string :page_label
      t.string :privacy
      t.string :short_description
      t.text :full_description

      t.timestamps
    end

    add_index :campaignmanager_pages, [:type, :privacy]
    add_index :campaignmanager_pages, [:campaign_id, :type, :slug], :unique => true
  end
end
