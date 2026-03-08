class CreateEntitybuilderSkills < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_skills, id: :string do |t|
      t.string :skillable_id
      t.string :skillable_type
      t.integer :sort_order
      t.string :name, null: false
      t.text :description
      t.integer :bonus
      t.boolean :class_skill
      t.string :ability_score
      t.integer :ranks
      t.integer :misc_modifier
      t.string :dice

      t.timestamps
    end

    add_index :entitybuilder_skills, [ :skillable_id, :skillable_type ], name: 'eb_skill_id_and_type'
    add_index :entitybuilder_skills, [ :skillable_id, :name ], unique: true, name: 'eb_skill_name'
  end
end
