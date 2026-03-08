class CreateWorldbuilderInhabitants < ActiveRecord::Migration[4.2]
  def change
    create_table :worldbuilder_inhabitants, id: :string do |t|
      t.string   :district_id, null: false
      t.string   :parent_id
      t.string   :plane_id
      t.string :name, null: false
      t.string :slug, null: false
      t.string :short_description
      t.text   :full_description

      t.timestamps
    end

    add_index :worldbuilder_inhabitants, [ :district_id, :slug ], unique: true
  end
end
