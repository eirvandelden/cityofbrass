# frozen_string_literal: false

class AddPrarentIdToAllTables < ActiveRecord::Migration
  def change
    add_column :rulebuilder_abilities, :parent_id, :uuid
    add_index  :rulebuilder_abilities, :parent_id

    add_column :rulebuilder_feats, :parent_id, :uuid
    add_index  :rulebuilder_feats, :parent_id

    add_column :rulebuilder_items, :parent_id, :uuid
    add_index  :rulebuilder_items, :parent_id

    add_column :rulebuilder_spells, :parent_id, :uuid
    add_index  :rulebuilder_spells, :parent_id
  end
end
