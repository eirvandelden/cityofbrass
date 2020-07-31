# frozen_string_literal: false

class CreateRulebuilderFeats < ActiveRecord::Migration
  def change
    create_table :rulebuilder_feats, id: :uuid do |t|
      t.string :type, :null => false
      t.uuid :resident_id
      t.string :core_rules
      t.string :name
      t.string :short_description
      t.text :full_description
      t.string :prerequisites
      t.text :benefit
      t.text :normal
      t.text :special

      t.timestamps null: false
    end

    add_index :rulebuilder_feats, :resident_id
  end
end
