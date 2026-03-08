class AddAddSpecialDamageNameToAttacks < ActiveRecord::Migration[4.2]
  def change
    add_column :entitybuilder_attacks, :special_damage_name, :string
  end
end
