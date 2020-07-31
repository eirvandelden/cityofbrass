# frozen_string_literal: false

class CreateWorldbuilderInhabitants < ActiveRecord::Migration
  def change
    create_table :worldbuilder_inhabitants, id: :uuid do |t|
      t.uuid   :district_id, :null => false
      t.uuid   :parent_id
      t.uuid   :plane_id
      t.string :name, :null => false
      t.string :slug, :null => false
      t.string :short_description
      t.text   :full_description

      t.timestamps
    end

    add_index :worldbuilder_inhabitants, [:district_id, :slug], :unique => true
  end
end
