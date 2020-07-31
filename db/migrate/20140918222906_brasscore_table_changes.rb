# frozen_string_literal: false

class BrasscoreTableChanges < ActiveRecord::Migration
  def change
    drop_table :component_features
    drop_table :component_menu_item_joins
    drop_table :component_menu_items
    drop_table :component_sections
  end
end
