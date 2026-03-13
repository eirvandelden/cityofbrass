class RemovePolymorphicFromKnownFeats < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_known_feats, :name =>  'eb_known_feat_id_and_type'

    rename_column :entitybuilder_known_feats, :known_featable_id, :entity_id

    add_index :entitybuilder_known_feats, :entity_id
  end
end
