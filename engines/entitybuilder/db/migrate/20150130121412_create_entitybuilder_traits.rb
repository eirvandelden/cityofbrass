class CreateEntitybuilderTraits < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_traits, id: :string do |t|
      t.string :traitable_id
      t.string :traitable_type
      t.integer :sort_order
      t.string :name, null: false
      t.string :short_description
      t.text :full_description

      t.timestamps
    end

    add_index :entitybuilder_traits, [ :traitable_id, :traitable_type ], name: 'eb_trait_id_and_type'
    add_index :entitybuilder_traits, [ :traitable_id, :name ], unique: true, name: 'eb_trait_name'
  end
end
