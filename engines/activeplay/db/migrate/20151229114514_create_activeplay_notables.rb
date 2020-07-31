# frozen_string_literal: false

class CreateActiveplayNotables < ActiveRecord::Migration
  def change
    create_table :activeplay_notables, id: :uuid do |t|
      t.string :name
      t.integer :sort_order
      t.uuid :virtual_table_id
      t.uuid :entity_id

      t.timestamps null: false
    end

    add_index :activeplay_notables, :virtual_table_id
    add_index :activeplay_notables, :entity_id
  end
end
