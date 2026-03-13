class RemovePolymorphicFromDefenses < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_defenses, :name =>  'eb_defense_id_and_type'
    remove_index :entitybuilder_defenses, :name =>  'eb_defense_name'

    rename_column :entitybuilder_defenses, :defenseable_id, :entity_id

    add_index :entitybuilder_defenses, :entity_id
  end
end
