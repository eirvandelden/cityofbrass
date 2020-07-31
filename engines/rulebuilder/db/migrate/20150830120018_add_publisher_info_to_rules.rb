# frozen_string_literal: false

class AddPublisherInfoToRules < ActiveRecord::Migration
  def change
    add_column :rulebuilder_abilities, :publisher, :string
    add_column :rulebuilder_abilities, :source, :string
    add_column :rulebuilder_abilities, :is_3pp, :boolean, :default => false
    add_column :rulebuilder_abilities, :tags, :text, array: true, default: []
    add_index  :rulebuilder_abilities, :tags, using: 'gin'

    add_column :rulebuilder_feats, :publisher, :string
    add_column :rulebuilder_feats, :source, :string
    add_column :rulebuilder_feats, :is_3pp, :boolean, :default => false
    add_column :rulebuilder_feats, :tags, :text, array: true, default: []
    add_index  :rulebuilder_feats, :tags, using: 'gin'

    add_column :rulebuilder_items, :publisher, :string
    add_column :rulebuilder_items, :source, :string
    add_column :rulebuilder_items, :is_3pp, :boolean, :default => false
    add_column :rulebuilder_items, :tags, :text, array: true, default: []
    add_index  :rulebuilder_items, :tags, using: 'gin'

    add_column :rulebuilder_spells, :publisher, :string
    add_column :rulebuilder_spells, :source, :string
    add_column :rulebuilder_spells, :is_3pp, :boolean, :default => false
    add_column :rulebuilder_spells, :tags, :text, array: true, default: []
    add_index  :rulebuilder_spells, :tags, using: 'gin'
  end
end
