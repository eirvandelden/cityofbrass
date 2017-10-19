class CreateEntitybuilderLinkedRules < ActiveRecord::Migration
  def change
    create_table :entitybuilder_linked_rules, id: :uuid do |t|
      t.uuid :entity_id
      t.uuid :rule_id
      t.integer :sort_order
      t.string :detail

      t.timestamps null: false
    end

    add_index :entitybuilder_linked_rules, :entity_id
    add_index :entitybuilder_linked_rules, :rule_id
  end
end
