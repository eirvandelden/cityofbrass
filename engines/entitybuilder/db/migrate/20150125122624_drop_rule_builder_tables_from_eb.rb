class DropRuleBuilderTablesFromEb < ActiveRecord::Migration[4.2]
  def change
    drop_table :entitybuilder_feats, if_exists: true
    drop_table :entitybuilder_items, if_exists: true
    drop_table :entitybuilder_spells, if_exists: true
  end
end
