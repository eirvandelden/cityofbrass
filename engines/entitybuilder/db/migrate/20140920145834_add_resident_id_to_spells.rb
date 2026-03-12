class AddResidentIdToSpells < ActiveRecord::Migration[4.2]
  def change
    remove_column :entitybuilder_spells, :prepared, :string
    remove_column :entitybuilder_spells, :sort_order, :integer

    add_column :entitybuilder_spells, :resident_id, :string
    add_column :entitybuilder_spells, :core_rules, :string

    add_index :entitybuilder_spells, :resident_id
  end
end
