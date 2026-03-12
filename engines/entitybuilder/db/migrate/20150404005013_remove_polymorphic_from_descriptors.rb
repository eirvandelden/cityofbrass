class RemovePolymorphicFromDescriptors < ActiveRecord::Migration[4.2]
  def change
    remove_index :entitybuilder_descriptors, name: 'eb_descriptor_id_and_type'
    remove_index :entitybuilder_descriptors, name: 'eb_descriptor_name'

    rename_column :entitybuilder_descriptors, :descriptorable_id, :entity_id

    add_index :entitybuilder_descriptors, :entity_id
  end
end
