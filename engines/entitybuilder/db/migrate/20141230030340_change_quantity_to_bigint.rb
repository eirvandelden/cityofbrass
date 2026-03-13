class ChangeQuantityToBigint < ActiveRecord::Migration
  def change
    change_column :entitybuilder_currencies, :quantity, :bigint
  end
end
