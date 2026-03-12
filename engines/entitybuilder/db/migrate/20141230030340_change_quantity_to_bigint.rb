class ChangeQuantityToBigint < ActiveRecord::Migration[4.2]
  def change
    change_column :entitybuilder_currencies, :quantity, :bigint
  end
end
