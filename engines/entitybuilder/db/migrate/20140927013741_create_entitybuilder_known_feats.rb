class CreateEntitybuilderKnownFeats < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_known_feats, id: :string do |t|
      t.string :known_featable_id
      t.string :known_featable_type
      t.integer :sort_order
      t.string :feat_id

      t.timestamps
    end

    add_index :entitybuilder_known_feats, :feat_id
    add_index :entitybuilder_known_feats, [ :known_featable_id, :known_featable_type ], name: 'eb_known_feat_id_and_type'
  end
end
