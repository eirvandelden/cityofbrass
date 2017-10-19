class RemovePolymorphicFromMovements < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_movements, :name =>  'eb_movement_id_and_type'
    remove_index :entitybuilder_movements, :name =>  'eb_movement_name'

    rename_column :entitybuilder_movements, :movementable_id, :entity_id

    add_index :entitybuilder_movements, :entity_id
  end
end
