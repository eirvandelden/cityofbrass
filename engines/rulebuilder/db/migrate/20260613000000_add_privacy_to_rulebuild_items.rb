class AddPrivacyToRulebuildItems < ActiveRecord::Migration[6.1]
  def up
    add_column :rulebuilder_items, :privacy, :string, default: 'Private', null: false
    add_index :rulebuilder_items, :privacy

    backfill_existing_stock_items
  end

  def down
    remove_index :rulebuilder_items, :privacy
    remove_column :rulebuilder_items, :privacy
  end

  private
    def backfill_existing_stock_items
      update(<<~SQL.squish)
        UPDATE #{quote_table_name(:rulebuilder_items)}
        SET privacy = 'Public'
        WHERE type = 'Rulebuilder::StockItem'
      SQL
    end
end
