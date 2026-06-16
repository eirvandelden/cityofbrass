class BrasscoreTableChanges < ActiveRecord::Migration[4.2]
  def change
    drop_table :component_features, if_exists: true
    drop_table :component_menu_item_joins, if_exists: true
    drop_table :component_menu_items, if_exists: true
    drop_table :component_sections, if_exists: true
  end
end
