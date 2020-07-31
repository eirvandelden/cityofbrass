# frozen_string_literal: false

class RemovePolymorphicFromBaseValues < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_base_values, :name =>  'eb_base_value_id_and_type'
    remove_index :entitybuilder_base_values, :name =>  'eb_base_value_name'

    rename_column :entitybuilder_base_values, :base_valueable_id, :entity_id

    add_index :entitybuilder_base_values, :entity_id
  end
end
