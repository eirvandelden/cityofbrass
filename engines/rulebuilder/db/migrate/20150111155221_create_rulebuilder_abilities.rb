class CreateRulebuilderAbilities < ActiveRecord::Migration[4.2]
  def change
    create_table :rulebuilder_abilities, id: :string do |t|
      t.string :type, null: false
      t.string :resident_id
      t.string :core_rules
      t.string :name
      t.string :short_description
      t.text :full_description

      t.timestamps null: false
    end

    add_index :rulebuilder_abilities, :resident_id
  end
end
