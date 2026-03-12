class AddAtWillToKnownSpells < ActiveRecord::Migration[4.2]
  def change
    add_column :entitybuilder_known_spells, :at_will, :boolean, default: false
  end
end
