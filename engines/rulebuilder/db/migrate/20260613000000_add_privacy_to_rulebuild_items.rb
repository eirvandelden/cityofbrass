class AddPrivacyToRulebuildItems < ActiveRecord::Migration[6.1]
  def change
    add_column :rulebuilder_items, :privacy, :string, default: 'Private', null: false
    add_index :rulebuilder_items, :privacy
  end
end
