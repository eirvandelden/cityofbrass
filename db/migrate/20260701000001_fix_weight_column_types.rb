class FixWeightColumnTypes < ActiveRecord::Migration[6.1]
  def up
    change_column :entitybuilder_currencies, :weight, :float
    change_column :rulebuilder_items, :weight, :float
  end

  def down
    change_column :entitybuilder_currencies, :weight, :decimal
    change_column :rulebuilder_items, :weight, :decimal
  end
end
