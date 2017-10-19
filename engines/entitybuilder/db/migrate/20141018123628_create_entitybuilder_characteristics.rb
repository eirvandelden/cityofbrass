class CreateEntitybuilderCharacteristics < ActiveRecord::Migration
  def change
    create_table :entitybuilder_characteristics, id: :uuid do |t|
      t.uuid :characteristicable_id
      t.string :characteristicable_type
      t.integer :sort_order
      t.string :name, :null => false
      t.string :short_description
      t.text :full_description

      t.timestamps
    end

    add_index :entitybuilder_characteristics, [:characteristicable_id, :characteristicable_type], :name => 'eb_characteristic_id_and_type'
    add_index :entitybuilder_characteristics, [:characteristicable_id, :name], :unique => true, :name => 'eb_characteristic_name'
  end
end
