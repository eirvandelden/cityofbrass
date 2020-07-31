# frozen_string_literal: false

class CreateRulebuilderRules < ActiveRecord::Migration
  def change
    create_table :rulebuilder_rules, id: :uuid do |t|
      t.string :type, :null => false
      t.uuid :resident_id
      t.uuid :parent_id
      t.string :core_rules
      t.string :rule_type
      t.boolean :is_shared
      t.string :name
      t.string :short_description
      t.text :full_description
      t.string :publisher
      t.string :source
      t.boolean :is_3pp
      t.text :tags, array: true, default: []
      t.text :categories, array: true, default: []
      t.string :prerequisites
      t.text :benefit
      t.text :normal
      t.text :special

      t.timestamps null: false
    end

    add_index :rulebuilder_rules, :resident_id
    add_index :rulebuilder_rules, :parent_id
    add_index :rulebuilder_rules, :type
    add_index :rulebuilder_rules, :tags, using: 'gin'
    add_index :rulebuilder_rules, :categories, using: 'gin'
  end
end
