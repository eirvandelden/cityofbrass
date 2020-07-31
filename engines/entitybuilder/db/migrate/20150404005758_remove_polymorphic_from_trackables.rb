# frozen_string_literal: false

class RemovePolymorphicFromTrackables < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_trackables, :name =>  'eb_trackable_id_and_type'
    remove_index :entitybuilder_trackables, :name =>  'eb_trackable_name'

    rename_column :entitybuilder_trackables, :trackableable_id, :entity_id

    add_index :entitybuilder_trackables, :entity_id
  end
end
