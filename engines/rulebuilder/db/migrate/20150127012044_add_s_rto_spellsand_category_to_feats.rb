# frozen_string_literal: false

class AddSRtoSpellsandCategoryToFeats < ActiveRecord::Migration
  def change
    add_column :rulebuilder_spells, :spell_resistance, :string

    add_column :rulebuilder_feats, :categories, :text, array: true, default: []
    add_index  :rulebuilder_feats, :categories, using: 'gin'
  end
end
