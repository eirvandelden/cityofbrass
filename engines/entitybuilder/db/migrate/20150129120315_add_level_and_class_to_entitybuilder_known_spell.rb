class AddLevelAndClassToEntitybuilderKnownSpell < ActiveRecord::Migration[4.2]
  def change
    add_column :entitybuilder_known_spells, :spell_class, :string
    add_column :entitybuilder_known_spells, :level, :integer
  end
end
