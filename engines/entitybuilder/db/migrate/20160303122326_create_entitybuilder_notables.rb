# frozen_string_literal: false

class CreateEntitybuilderNotables < ActiveRecord::Migration
  def change
    create_table :entitybuilder_notables, id: :uuid do |t|
      t.uuid :notableable_id
      t.string :notableable_type
      t.uuid :entity_id
      t.string :name
      t.integer :sort_order

      t.timestamps null: false
    end

    add_index :entitybuilder_notables, :entity_id
    add_index :entitybuilder_notables, [:notableable_id, :notableable_type], :name => 'eb_notable_id_and_type'
  end
end
