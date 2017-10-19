class CreateEntitybuilderCurrencies < ActiveRecord::Migration
  def change
    create_table :entitybuilder_currencies, id: :uuid do |t|
      t.uuid :currencyable_id
      t.string :currencyable_type
      t.integer :sort_order
      t.string :name
      t.text :description
      t.decimal :weight
      t.integer :quantity
      t.boolean :equipped

      t.timestamps
    end

    add_index :entitybuilder_currencies, [:currencyable_id, :currencyable_type], :name => 'eb_currency_id_and_type'
    add_index :entitybuilder_currencies, [:currencyable_id, :name], :unique => true, :name => 'eb_currency_name'
  end
end
