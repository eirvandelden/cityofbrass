class AddAdditionalDamageToAttacks < ActiveRecord::Migration
  def change
    add_column :entitybuilder_attacks, :damage_type, :string

    add_column :entitybuilder_attacks, :critical_damage_ability_score, :string
    add_column :entitybuilder_attacks, :critical_damage_dice, :string
    add_column :entitybuilder_attacks, :critical_damage_bonus, :integer
    add_column :entitybuilder_attacks, :critical_damage_misc_modifier, :integer

    add_column :entitybuilder_attacks, :special_damage_ability_score, :string
    add_column :entitybuilder_attacks, :special_damage_dice, :string
    add_column :entitybuilder_attacks, :special_damage_bonus, :integer
    add_column :entitybuilder_attacks, :special_damage_misc_modifier, :integer

    remove_column :entitybuilder_attacks, :critical_damage, :string
  end
end
