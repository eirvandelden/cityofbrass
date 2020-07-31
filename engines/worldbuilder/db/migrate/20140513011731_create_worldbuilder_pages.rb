# frozen_string_literal: false

class CreateWorldbuilderPages < ActiveRecord::Migration
  def change
    create_table :worldbuilder_pages, id: :uuid do |t|
      t.string :type
      t.uuid :district_id
      t.uuid :parent_id
      t.string :name
      t.string :slug
      t.string :page_label
      t.string :short_description
      t.text :full_description

      t.timestamps
    end

    add_index :worldbuilder_pages, [:id, :type]
    add_index :worldbuilder_pages, [:district_id, :type, :slug], :unique => true
  end
end
