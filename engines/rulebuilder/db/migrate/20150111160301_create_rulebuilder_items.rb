# frozen_string_literal: false

class CreateRulebuilderItems < ActiveRecord::Migration
  def change
    create_table :rulebuilder_items, id: :uuid do |t|
      t.string :type, :null => false
      t.uuid :resident_id
      t.string :core_rules
      t.string :name
      t.string :short_description
      t.text :full_description
      t.text :category
      t.decimal :weight

      t.timestamps null: false
    end

    add_index :rulebuilder_items, :resident_id
  end
end
