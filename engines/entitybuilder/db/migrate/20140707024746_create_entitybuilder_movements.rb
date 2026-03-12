class CreateEntitybuilderMovements < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_movements, id: :string do |t|
      t.string :movementable_id
      t.string :movementable_type
      t.integer :sort_order
      t.string :name, null: false
      t.text :description
      t.integer :distance
      t.string :measurement

      t.timestamps
    end

    add_index :entitybuilder_movements, [ :movementable_id, :movementable_type ], name: 'eb_movement_id_and_type'
    add_index :entitybuilder_movements, [ :movementable_id, :name ], unique: true, name: 'eb_movement_name'
  end
end
