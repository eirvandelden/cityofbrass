# frozen_string_literal: false

class AddLevelAndClassToEntitybuilderKnownSpell < ActiveRecord::Migration
  def change
    add_column :entitybuilder_known_spells, :spell_class, :string
    add_column :entitybuilder_known_spells, :level, :integer
  end
end
