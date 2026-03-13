class CreateEntitybuilderDescriptors < ActiveRecord::Migration
  def change
    create_table :entitybuilder_descriptors, id: :uuid do |t|
      t.uuid :descriptorable_id
      t.string :descriptorable_type
      t.integer :sort_order
      t.string :name, :null => false
      t.string :description

      t.timestamps
    end

    add_index :entitybuilder_descriptors, [:descriptorable_id, :descriptorable_type], :name => 'eb_descriptor_id_and_type'
    add_index :entitybuilder_descriptors, [:descriptorable_id, :name], :unique => true, :name => 'eb_descriptor_name'
  end
end
