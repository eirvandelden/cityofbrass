class CreateEntitybuilderClassLevels < ActiveRecord::Migration
  def change
    create_table :entitybuilder_class_levels, id: :uuid do |t|
      t.uuid :class_levelable_id
      t.string :class_levelable_type
      t.integer :sort_order
      t.string :name, :null => false
      t.text :description
      t.integer :level
      t.string :hit_dice
      t.integer :hit_points

      t.timestamps
    end

    add_index :entitybuilder_class_levels, [:class_levelable_id, :class_levelable_type], :name => 'eb_class_level_id_and_type'
    add_index :entitybuilder_class_levels, [:class_levelable_id, :name], :unique => true, :name => 'eb_class_level_name'
  end
end
