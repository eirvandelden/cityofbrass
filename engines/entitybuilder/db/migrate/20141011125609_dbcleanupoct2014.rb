class Dbcleanupoct2014 < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_feats, :name => 'eb_feat_id_and_type'
    remove_index :entitybuilder_feats, :name => 'eb_feat_name'
    remove_column :entitybuilder_feats, :featable_id, :uuid
    remove_column :entitybuilder_feats, :featable_type, :string

    remove_index :entitybuilder_spells, :name => 'eb_spell_id_and_type'
    remove_index :entitybuilder_spells, :name => 'eb_spell_name'
    remove_column :entitybuilder_spells, :spellable_id, :uuid
    remove_column :entitybuilder_spells, :spellable_type, :string

    remove_index :entitybuilder_items, :name => 'eb_item_id_and_type'
    remove_index :entitybuilder_items, :name => 'eb_item_name'
    remove_column :entitybuilder_items, :itemable_id, :uuid
    remove_column :entitybuilder_items, :itemable_type, :string
    remove_column :entitybuilder_items, :quantity, :string
    remove_column :entitybuilder_items, :equipped, :string
  end
end
