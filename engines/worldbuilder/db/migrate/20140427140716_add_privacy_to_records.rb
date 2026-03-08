class AddPrivacyToRecords < ActiveRecord::Migration[4.2]
  def change
    remove_column :worldbuilder_districts, :privacy, :string
    add_column :worldbuilder_districts, :privacy, :string
  end
end
