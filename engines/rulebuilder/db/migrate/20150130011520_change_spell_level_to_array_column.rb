class ChangeSpellLevelToArrayColumn < ActiveRecord::Migration[4.2]
  def change
    remove_column :rulebuilder_spells, :level, :integer

    add_column :rulebuilder_spells, :levels, :text
    add_index  :rulebuilder_spells, :levels, using: 'gin'
  end
end
