class RemovePolymorphicFromModifiers < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_modifiers, :name =>  'eb_modifier_entity_id_and_type'

    rename_column :entitybuilder_modifiers, :entityable_id, :entity_id

    add_index :entitybuilder_modifiers, :entity_id
  end
end
