# frozen_string_literal: false

class RemovePolymorphicFromClassLevels < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_class_levels, :name =>  'eb_class_level_id_and_type'

    rename_column :entitybuilder_class_levels, :class_levelable_id, :entity_id

    add_index :entitybuilder_class_levels, :entity_id
  end
end
