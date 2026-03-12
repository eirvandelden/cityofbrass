class AddSheetPrivacyToEntitybuilderCreature < ActiveRecord::Migration[4.2]
  def change
    add_column :entitybuilder_creatures, :sheet_privacy, :string
  end
end
