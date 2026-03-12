class CreateCampaignmanagerCampaigns < ActiveRecord::Migration[4.2]
  def change
    create_table :campaignmanager_campaigns, id: :string do |t|
      t.string :resident_id, null: false
      t.string :name, null: false
      t.string :slug, null: false
      t.string :page_label
      t.string :privacy, null: false
      t.string :short_description
      t.text :full_description

      t.timestamps
    end

    add_index :campaignmanager_campaigns, :privacy
    add_index :campaignmanager_campaigns, [ :resident_id, :slug ], unique: true
  end
end
