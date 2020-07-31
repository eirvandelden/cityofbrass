# frozen_string_literal: false

class CreateStorybuilderMenuItemJoins < ActiveRecord::Migration
  def change
    create_table :storybuilder_menu_item_joins, id: :uuid do |t|
      t.uuid :menu_item_id, :null => false
      t.uuid :menu_item_joinable_id, :null => false
      t.string :menu_item_joinable_type, :null => false

      t.timestamps
    end

    add_index :storybuilder_menu_item_joins, [:menu_item_joinable_id, :menu_item_joinable_type], :name => 'sb_menu_item_join_id_and_type'
  end
end
