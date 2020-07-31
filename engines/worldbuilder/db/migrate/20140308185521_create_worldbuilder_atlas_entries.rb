# frozen_string_literal: false

class CreateWorldbuilderAtlasEntries < ActiveRecord::Migration
  def change
    create_table :worldbuilder_atlas_entries, id: :uuid do |t|
      t.uuid   :district_id, :null => false
      t.uuid   :parent_id
      t.uuid   :plane_id
      t.string :name, :null => false
      t.string :slug, :null => false
      t.string :short_description
      t.text   :full_description
      t.string :entry_type
      t.string :entry_label

      t.timestamps
    end

    add_index :worldbuilder_atlas_entries, [:district_id, :slug], :unique => true
  end
end
