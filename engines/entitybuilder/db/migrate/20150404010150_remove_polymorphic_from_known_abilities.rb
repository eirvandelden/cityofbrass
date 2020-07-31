# frozen_string_literal: false

class RemovePolymorphicFromKnownAbilities < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_known_abilities, :name =>  'eb_known_ability_id_and_type'

    rename_column :entitybuilder_known_abilities, :known_abilityable_id, :entity_id

    add_index :entitybuilder_known_abilities, :entity_id
  end
end
