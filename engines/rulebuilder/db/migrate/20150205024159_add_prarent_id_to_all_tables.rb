class AddPrarentIdToAllTables < ActiveRecord::Migration[4.2]
  def change
    add_column :rulebuilder_abilities, :parent_id, :string
    add_index  :rulebuilder_abilities, :parent_id

    add_column :rulebuilder_feats, :parent_id, :string
    add_index  :rulebuilder_feats, :parent_id

    add_column :rulebuilder_items, :parent_id, :string
    add_index  :rulebuilder_items, :parent_id

    add_column :rulebuilder_spells, :parent_id, :string
    add_index  :rulebuilder_spells, :parent_id
  end
end
