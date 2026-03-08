class CreateStorybuilderPages < ActiveRecord::Migration[4.2]
  def change
    create_table :storybuilder_pages, id: :string do |t|
      t.string :type, null: false
      t.string :resident_id
      t.string :parent_id
      t.string :name, null: false
      t.string :slug, null: false
      t.string :page_label
      t.string :privacy, null: false
      t.string :short_description
      t.text :full_description

      t.timestamps
    end

    add_index :storybuilder_pages, [ :type, :privacy ]
    add_index :storybuilder_pages, [ :resident_id, :type, :slug ], unique: true
  end
end
