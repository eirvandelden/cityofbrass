class ChangeMenuItemJoin < ActiveRecord::Migration
  def change
    remove_index :worldbuilder_menu_item_joins, :name => 'wb_menu_item_joins_id_and_type'
    rename_column :worldbuilder_menu_item_joins, :menu_itemable_id, :menu_item_joinable_id
    rename_column :worldbuilder_menu_item_joins, :menu_itemable_type, :menu_item_joinable_type
    add_index :worldbuilder_menu_item_joins, [:menu_item_joinable_id, :menu_item_joinable_type], :name => 'wb_menu_item_joins_id_and_type'
  end
end
