class AddPowerFieldsToEntitybuilderAttacks < ActiveRecord::Migration[8.1]
  def change
    add_column :entitybuilder_attacks, :power_usage, :string, limit: 16
    add_column :entitybuilder_attacks, :action_type, :string, limit: 24, null: false, default: "Standard"
    add_column :entitybuilder_attacks, :multi_target, :boolean, null: false, default: false
    add_column :entitybuilder_attacks, :recharges_when_bloodied, :boolean, null: false, default: false
    add_column :entitybuilder_attacks, :usable_at_will, :boolean, null: false, default: false
  end
end
