# frozen_string_literal: false

class CreateEntitybuilderSavingThrows < ActiveRecord::Migration
  def change
    create_table :entitybuilder_saving_throws, id: :uuid do |t|
      t.uuid :saving_throwable_id
      t.string :saving_throwable_type
      t.integer :sort_order
      t.string :name
      t.text :description
      t.integer :base
      t.integer :bonus
      t.string :ability_score
      t.integer :misc_modifier
      t.string :dice

      t.timestamps
    end

    add_index :entitybuilder_saving_throws, [:saving_throwable_id, :saving_throwable_type], :name => 'eb_saving_throw_id_and_type'
    add_index :entitybuilder_saving_throws, [:saving_throwable_id, :name], :unique => true, :name => 'eb_saving_throw_name'
  end
end
