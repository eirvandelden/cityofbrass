# frozen_string_literal: false

class CreateWorldbuilderMenuItemJoins < ActiveRecord::Migration
  def change
    create_table :worldbuilder_menu_item_joins, id: :uuid do |t|
      t.uuid :menu_item_id, :null => false
      t.uuid :menu_itemable_id, :null => false
      t.string :menu_itemable_type, :null => false

      t.timestamps
    end

    add_index :worldbuilder_menu_item_joins, [:menu_itemable_id, :menu_itemable_type], :name => 'wb_menu_item_joins_id_and_type'
  end
end
