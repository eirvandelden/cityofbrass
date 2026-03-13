class CreateCampaignmanagerCampaigns < ActiveRecord::Migration
  def change
    create_table :campaignmanager_campaigns, id: :uuid do |t|
      t.uuid :resident_id, :null => false
      t.string :name, :null => false
      t.string :slug, :null => false
      t.string :page_label
      t.string :privacy, :null => false
      t.string :short_description
      t.text :full_description

      t.timestamps
    end

    add_index :campaignmanager_campaigns, :privacy
    add_index :campaignmanager_campaigns, [:resident_id, :slug], :unique => true
  end
end
