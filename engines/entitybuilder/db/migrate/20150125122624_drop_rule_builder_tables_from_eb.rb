class DropRuleBuilderTablesFromEb < ActiveRecord::Migration[4.2]
  def change
    drop_table :entitybuilder_feats
    drop_table :entitybuilder_items
    drop_table :entitybuilder_spells
  end
end
