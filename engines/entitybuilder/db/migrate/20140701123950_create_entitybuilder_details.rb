# frozen_string_literal: false

class CreateEntitybuilderDetails < ActiveRecord::Migration
  def change
    create_table :entitybuilder_details, id: :uuid do |t|
      t.uuid :detailable_id
      t.string :detailable_type
      t.integer :sort_order
      t.string :name, :null => false
      t.text :description
      t.string :value
      t.string :dice

      t.timestamps
    end

    add_index :entitybuilder_details, [:detailable_id, :detailable_type], :name => 'eb_detail_id_and_type'
    add_index :entitybuilder_details, [:detailable_id, :name], :unique => true, :name => 'eb_detail_name'
  end
end
