class AddRulebuilderTypeIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :rulebuilder_abilities, :type
    add_index :rulebuilder_feats, :type
    add_index :rulebuilder_items, :type
    add_index :rulebuilder_spells, :type
  end
end
