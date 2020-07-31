# frozen_string_literal: false

class CreateStorybuilderAdventures < ActiveRecord::Migration
  def change
    create_table :storybuilder_adventures, id: :uuid do |t|
      t.uuid :resident_id, :null => false
      t.uuid :parent_id
      t.string :name, :null => false
      t.string :slug, :null => false
      t.string :page_label
      t.string :privacy, :null => false
      t.string :short_description
      t.text :full_description

      t.timestamps
    end

    add_index :storybuilder_adventures, :privacy
    add_index :storybuilder_adventures, [:resident_id, :slug], :unique => true
  end
end
