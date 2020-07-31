# frozen_string_literal: false

class RenameCurrencyEquippedToCarried < ActiveRecord::Migration
  def change
    rename_column :entitybuilder_currencies, :equipped, :carried
  end
end
