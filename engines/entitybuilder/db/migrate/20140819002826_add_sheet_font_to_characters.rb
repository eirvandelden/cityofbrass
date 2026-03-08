class AddSheetFontToCharacters < ActiveRecord::Migration[4.2]
  def change
    add_column :entitybuilder_characters, :sheet_font, :string
  end
end
