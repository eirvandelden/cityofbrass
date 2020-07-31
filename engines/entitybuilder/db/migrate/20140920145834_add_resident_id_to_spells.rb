# frozen_string_literal: false

class AddResidentIdToSpells < ActiveRecord::Migration
  def change
    remove_column :entitybuilder_spells, :prepared, :uuid
    remove_column :entitybuilder_spells, :sort_order, :integer

    add_column :entitybuilder_spells, :resident_id, :uuid
    add_column :entitybuilder_spells, :core_rules, :string

    add_index :entitybuilder_spells, :resident_id
  end
end
