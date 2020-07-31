# frozen_string_literal: false

class CreateEntitybuilderFeats < ActiveRecord::Migration
  def change
    create_table :entitybuilder_feats, id: :uuid do |t|
      t.uuid :featable_id
      t.string :featable_type
      t.integer :sort_order
      t.string :name, :null => false
      t.string :short_description
      t.text :full_description
      t.string :prerequisites
      t.text :benefit
      t.text :normal
      t.text :special

      t.timestamps
    end

    add_index :entitybuilder_feats, [:featable_id, :featable_type], :name => 'eb_feat_id_and_type'
    add_index :entitybuilder_feats, [:featable_id, :name], :unique => true, :name => 'eb_feat_name'
  end
end
