# frozen_string_literal: false

class AddAddSpecialDamageNameToAttacks < ActiveRecord::Migration
  def change
    add_column :entitybuilder_attacks, :special_damage_name, :string
  end
end
