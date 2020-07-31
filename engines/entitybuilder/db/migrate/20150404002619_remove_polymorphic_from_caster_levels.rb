# frozen_string_literal: false

class RemovePolymorphicFromCasterLevels < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_caster_levels, :name =>  'eb_caster_level_id_and_type'

    rename_column :entitybuilder_caster_levels, :caster_levelable_id, :entity_id

    add_index :entitybuilder_caster_levels, :entity_id
  end
end
