class RemovePolymorphicFromSkills < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_skills, :name =>  'eb_skill_id_and_type'
    remove_index :entitybuilder_skills, :name =>  'eb_skill_name'

    rename_column :entitybuilder_skills, :skillable_id, :entity_id

    add_index :entitybuilder_skills, :entity_id
  end
end
