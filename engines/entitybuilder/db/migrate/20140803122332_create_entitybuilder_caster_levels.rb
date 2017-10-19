class CreateEntitybuilderCasterLevels < ActiveRecord::Migration
  def change
    create_table :entitybuilder_caster_levels, id: :uuid do |t|
      t.uuid :caster_levelable_id
      t.string :caster_levelable_type
      t.integer :sort_order
      t.string :caster_class
      t.integer :level
      t.integer :per_day
      t.integer :bonus_per_day
      t.integer :base_dc
      t.string :ability_score
      t.integer :save_dc

      t.timestamps
    end

    add_index :entitybuilder_caster_levels, [:caster_levelable_id, :caster_levelable_type], :name => 'eb_caster_level_id_and_type'
  end
end
