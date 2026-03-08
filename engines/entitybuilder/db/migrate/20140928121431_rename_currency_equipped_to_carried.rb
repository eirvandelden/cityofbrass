class RenameCurrencyEquippedToCarried < ActiveRecord::Migration[4.2]
  def change
    rename_column :entitybuilder_currencies, :equipped, :carried
  end
end
