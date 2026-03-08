class CreateCampaignmanagerPages < ActiveRecord::Migration[4.2]
  def change
    create_table :campaignmanager_pages, id: :string do |t|
      t.string :type, null: false
      t.string :resident_id
      t.string :campaign_id
      t.string :parent_id
      t.string :name
      t.string :slug
      t.string :page_label
      t.string :privacy
      t.string :short_description
      t.text :full_description

      t.timestamps
    end

    add_index :campaignmanager_pages, [ :type, :privacy ]
    add_index :campaignmanager_pages, [ :campaign_id, :type, :slug ], unique: true
  end
end
