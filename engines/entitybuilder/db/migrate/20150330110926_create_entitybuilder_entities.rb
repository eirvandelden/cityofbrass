# frozen_string_literal: false

class CreateEntitybuilderEntities < ActiveRecord::Migration
  def change
    create_table :entitybuilder_entities, id: :uuid do |t|
      t.string :type, :null => false
      t.uuid :resident_id
      t.string :name
      t.string :core_rules
      t.string :privacy
      t.string :sheet_privacy
      t.string :short_description
      t.text :full_description
      t.text :introduction
      t.text :notes

      t.timestamps null: false
    end

    add_index :entitybuilder_entities, :type
    add_index :entitybuilder_entities, :resident_id
  end
end
