class CreateEntitybuilderAttacks < ActiveRecord::Migration
  def change
    create_table :entitybuilder_attacks, id: :uuid do |t|
      t.uuid :attackable_id
      t.string :attackable_type
      t.integer :sort_order
      t.string :name, :null => false
      t.text :description
      t.string :attack_type
      t.string :attack_range
      t.string :attack_ability_score
      t.string :attack_dice
      t.integer :attack_bonus
      t.integer :attack_misc_modifier
      t.string :damage_ability_score
      t.string :damage_dice
      t.integer :damage_bonus
      t.integer :damage_misc_modifier
      t.string :critical_range
      t.string :critical_damage

      t.timestamps
    end

    add_index :entitybuilder_attacks, [:attackable_id, :attackable_type], :name => 'eb_attack_id_and_type'
    add_index :entitybuilder_attacks, [:attackable_id, :name], :unique => true, :name => 'eb_attack_name'
  end
end
