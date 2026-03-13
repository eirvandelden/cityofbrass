class CreateEntitybuilderDefenses < ActiveRecord::Migration
  def change
    create_table :entitybuilder_defenses, id: :uuid do |t|
      t.uuid :defenseable_id
      t.string :defenseable_type
      t.integer :sort_order
      t.string :name, :null => false
      t.text :description
      t.integer :base
      t.integer :bonus
      t.string :ability_score
      t.integer :misc_modifier
      t.string :dice

      t.timestamps
    end

    add_index :entitybuilder_defenses, [:defenseable_id, :defenseable_type], :name => 'eb_defense_id_and_type'
    add_index :entitybuilder_defenses, [:defenseable_id, :name], :unique => true, :name => 'eb_defense_name'
  end
end
