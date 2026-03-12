class CreateRulebuilderSpells < ActiveRecord::Migration[4.2]
  def change
    create_table :rulebuilder_spells, id: :string do |t|
      t.string :type, null: false
      t.string :resident_id
      t.string :core_rules
      t.string :name
      t.string :short_description
      t.text :full_description
      t.string :school
      t.integer :level
      t.string :casting_time
      t.string :components
      t.string :range
      t.string :effect
      t.string :target
      t.string :area
      t.string :duration
      t.string :saving_throw

      t.timestamps null: false
    end

    add_index :rulebuilder_spells, :resident_id
  end
end
