class CreateEntitybuilderLinkedRules < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_linked_rules, id: :string do |t|
      t.string :entity_id
      t.string :rule_id
      t.integer :sort_order
      t.string :detail

      t.timestamps null: false
    end

    add_index :entitybuilder_linked_rules, :entity_id
    add_index :entitybuilder_linked_rules, :rule_id
  end
end
