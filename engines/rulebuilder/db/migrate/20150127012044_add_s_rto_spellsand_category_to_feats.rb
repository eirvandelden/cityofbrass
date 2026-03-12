class AddSRtoSpellsandCategoryToFeats < ActiveRecord::Migration[4.2]
  def change
    add_column :rulebuilder_spells, :spell_resistance, :string

    add_column :rulebuilder_feats, :categories, :text
    add_index  :rulebuilder_feats, :categories, using: 'gin'
  end
end
