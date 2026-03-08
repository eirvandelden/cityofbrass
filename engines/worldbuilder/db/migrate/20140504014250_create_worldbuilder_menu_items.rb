class CreateWorldbuilderMenuItems < ActiveRecord::Migration[4.2]
  def change
    create_table :worldbuilder_menu_items, id: :string do |t|
      t.string :menu_itemable_id
      t.string :menu_itemable_type
      t.integer :sort_order
      t.string :item_label
      t.string :item_link

      t.timestamps
    end

    add_index :worldbuilder_menu_items, [ :menu_itemable_id, :menu_itemable_type ], name: 'wb_menu_items_id_and_type'
  end
end
