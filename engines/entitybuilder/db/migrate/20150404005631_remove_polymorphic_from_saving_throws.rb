# frozen_string_literal: false

class RemovePolymorphicFromSavingThrows < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_saving_throws, :name =>  'eb_saving_throw_id_and_type'
    remove_index :entitybuilder_saving_throws, :name =>  'eb_saving_throw_name'

    rename_column :entitybuilder_saving_throws, :saving_throwable_id, :entity_id

    add_index :entitybuilder_saving_throws, :entity_id
  end
end
