class AddColumnsToEntitybuilderMovements < ActiveRecord::Migration[4.2]
  def change
    remove_column :entitybuilder_movements, :description
    rename_column :entitybuilder_movements, :distance, :base
    rename_column :entitybuilder_movements, :measurement, :description
    add_column :entitybuilder_movements, :bonus, :integer
    add_column :entitybuilder_movements, :ability_score, :string
    add_column :entitybuilder_movements, :misc_modifier, :integer
    add_column :entitybuilder_movements, :dice, :string
  end
end
