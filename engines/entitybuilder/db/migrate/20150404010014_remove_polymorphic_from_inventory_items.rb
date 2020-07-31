# frozen_string_literal: false

class RemovePolymorphicFromInventoryItems < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_inventory_items, :name =>  'eb_inventory_item_id_and_type'

    rename_column :entitybuilder_inventory_items, :inventory_itemable_id, :entity_id

    add_index :entitybuilder_inventory_items, :entity_id
  end
end
