class CreateWorldbuilderPages < ActiveRecord::Migration[4.2]
  def change
    create_table :worldbuilder_pages, id: :string do |t|
      t.string :type
      t.string :district_id
      t.string :parent_id
      t.string :name
      t.string :slug
      t.string :page_label
      t.string :short_description
      t.text :full_description

      t.timestamps
    end

    add_index :worldbuilder_pages, [ :id, :type ]
    add_index :worldbuilder_pages, [ :district_id, :type, :slug ], unique: true
  end
end
