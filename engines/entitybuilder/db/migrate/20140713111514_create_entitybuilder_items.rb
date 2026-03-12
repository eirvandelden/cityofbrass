class CreateEntitybuilderItems < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_items, id: :string do |t|
      t.string :itemable_id
      t.string :itemable_type
      t.integer :sort_order
      t.string :name, null: false
      t.string :short_description
      t.text :full_description
      t.text :category
      t.decimal :weight
      t.integer :quantity
      t.boolean :equipped

      t.timestamps
    end

    add_index :entitybuilder_items, [ :itemable_id, :itemable_type ], name: 'eb_item_id_and_type'
    add_index :entitybuilder_items, [ :itemable_id, :name ], unique: true, name: 'eb_item_name'
  end
end
