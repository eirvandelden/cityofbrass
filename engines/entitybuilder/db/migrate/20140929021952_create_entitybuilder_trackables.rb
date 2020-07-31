# frozen_string_literal: false

class CreateEntitybuilderTrackables < ActiveRecord::Migration
  def change
    create_table :entitybuilder_trackables, id: :uuid do |t|
      t.uuid :trackableable_id
      t.string :trackableable_type
      t.integer :sort_order
      t.string :name, :null => false
      t.text :description
      t.integer :minimum
      t.integer :maximum
      t.integer :current
      t.integer :temporary

      t.timestamps
    end

    add_index :entitybuilder_trackables, [:trackableable_id, :trackableable_type], :name => 'eb_trackable_id_and_type'
    add_index :entitybuilder_trackables, [:trackableable_id, :name], :unique => true, :name => 'eb_trackable_name'
  end
end
