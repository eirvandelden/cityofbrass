class AddAtWillToKnownSpells < ActiveRecord::Migration
  def change
    add_column :entitybuilder_known_spells, :at_will, :boolean, :default => false
  end
end
