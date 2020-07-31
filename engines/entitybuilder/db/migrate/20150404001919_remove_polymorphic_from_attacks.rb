# frozen_string_literal: false

class RemovePolymorphicFromAttacks < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_attacks, :name =>  'eb_attack_id_and_type'
    remove_index :entitybuilder_attacks, :name =>  'eb_attack_name'

    rename_column :entitybuilder_attacks, :attackable_id, :entity_id

    add_index :entitybuilder_attacks, :entity_id
  end
end
