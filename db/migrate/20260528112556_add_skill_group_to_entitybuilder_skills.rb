class AddSkillGroupToEntitybuilderSkills < ActiveRecord::Migration[6.1]
  def change
    add_column :entitybuilder_skills, :skill_group, :string, limit: 64
    add_index  :entitybuilder_skills, [ :entity_id, :skill_group ]
  end
end
