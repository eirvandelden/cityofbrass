class CreateEntitybuilderInventoryItems < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_inventory_items, id: :string do |t|
      t.string :inventory_itemable_id
      t.string :inventory_itemable_type
      t.integer :sort_order
      t.string :item_id
      t.integer :quantity
      t.boolean :equipped
      t.boolean :carried

      t.timestamps
    end

    add_index :entitybuilder_inventory_items, :item_id
    add_index :entitybuilder_inventory_items, [ :inventory_itemable_id, :inventory_itemable_type ], name: 'eb_inventory_item_id_and_type'
  end
end
