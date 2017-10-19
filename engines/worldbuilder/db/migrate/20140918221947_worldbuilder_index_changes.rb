class WorldbuilderIndexChanges < ActiveRecord::Migration
  def change
    add_index :worldbuilder_districts, :resident_id
    add_index :worldbuilder_menu_item_joins, :menu_item_id

    remove_index :worldbuilder_pages, [:id, :type]
    add_index :worldbuilder_pages, :parent_id

  end
end
