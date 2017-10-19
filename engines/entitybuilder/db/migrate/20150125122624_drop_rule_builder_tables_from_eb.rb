class DropRuleBuilderTablesFromEb < ActiveRecord::Migration
  def change
    drop_table :entitybuilder_feats
    drop_table :entitybuilder_items
    drop_table :entitybuilder_spells
  end
end
