class CreateStorybuilderCampaigns < ActiveRecord::Migration[4.2]
  def change
    create_table :storybuilder_campaigns, id: :string do |t|
      t.string :resident_id, null: false
      t.string :parent_id
      t.string :name, null: false
      t.string :slug, null: false
      t.string :page_label
      t.string :privacy, null: false
      t.string :short_description
      t.text :full_description

      t.timestamps
    end

    add_index :storybuilder_campaigns, :privacy
    add_index :storybuilder_campaigns, [ :resident_id, :slug ], unique: true
  end
end
