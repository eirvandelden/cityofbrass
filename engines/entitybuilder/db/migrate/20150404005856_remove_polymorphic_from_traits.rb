class RemovePolymorphicFromTraits < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_traits, :name =>  'eb_trait_id_and_type'
    remove_index :entitybuilder_traits, :name =>  'eb_trait_name'

    rename_column :entitybuilder_traits, :traitable_id, :entity_id

    add_index :entitybuilder_traits, :entity_id
  end
end
