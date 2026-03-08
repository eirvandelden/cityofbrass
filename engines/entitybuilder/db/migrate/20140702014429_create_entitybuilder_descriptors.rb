class CreateEntitybuilderDescriptors < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_descriptors, id: :string do |t|
      t.string :descriptorable_id
      t.string :descriptorable_type
      t.integer :sort_order
      t.string :name, null: false
      t.string :description

      t.timestamps
    end

    add_index :entitybuilder_descriptors, [ :descriptorable_id, :descriptorable_type ], name: 'eb_descriptor_id_and_type'
    add_index :entitybuilder_descriptors, [ :descriptorable_id, :name ], unique: true, name: 'eb_descriptor_name'
  end
end
