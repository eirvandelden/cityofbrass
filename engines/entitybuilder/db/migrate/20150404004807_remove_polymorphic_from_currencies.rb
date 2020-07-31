# frozen_string_literal: false

class RemovePolymorphicFromCurrencies < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_currencies, :name =>  'eb_currency_id_and_type'
    remove_index :entitybuilder_currencies, :name =>  'eb_currency_name'

    rename_column :entitybuilder_currencies, :currencyable_id, :entity_id

    add_index :entitybuilder_currencies, :entity_id
  end
end
