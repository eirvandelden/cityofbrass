class CreateEntitybuilderBaseValues < ActiveRecord::Migration
  def change
    create_table :entitybuilder_base_values, id: :uuid do |t|
      t.uuid :base_valueable_id
      t.string :base_valueable_type
      t.integer :sort_order
      t.string :name, :null => false
      t.text :description
      t.integer :value
      t.string :dice

      t.timestamps
    end

    add_index :entitybuilder_base_values, [:base_valueable_id, :base_valueable_type], :name => 'eb_base_value_id_and_type'
    add_index :entitybuilder_base_values, [:base_valueable_id, :name], :unique => true, :name => 'eb_base_value_name'
  end
end
