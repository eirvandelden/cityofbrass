class AddMonsterBuilderToEntitybuilderEntities < ActiveRecord::Migration[8.1]
  def change
    add_column :entitybuilder_entities, :monster_level, :integer
    add_column :entitybuilder_entities, :monster_role, :string, limit: 16
    add_column :entitybuilder_entities, :monster_group, :string, limit: 16
    add_column :entitybuilder_entities, :monster_defense_bonuses, :text, default: "[]"
    add_column :entitybuilder_entities, :monster_extra_action, :boolean
  end
end
