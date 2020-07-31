# frozen_string_literal: false

class RemovePolymorphicFromKnownSpells < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_known_spells, :name =>  'eb_known_spell_id_and_type'

    rename_column :entitybuilder_known_spells, :known_spellable_id, :entity_id

    add_index :entitybuilder_known_spells, :entity_id
  end
end
