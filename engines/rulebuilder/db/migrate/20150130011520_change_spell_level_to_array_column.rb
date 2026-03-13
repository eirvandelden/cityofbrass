class ChangeSpellLevelToArrayColumn < ActiveRecord::Migration
  def change
    remove_column :rulebuilder_spells, :level, :integer

    add_column :rulebuilder_spells, :levels, :text, array: true, default: []
    add_index  :rulebuilder_spells, :levels, using: 'gin'
  end
end
