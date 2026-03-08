class RemoveColumnsFromEntitybuilderCharacters < ActiveRecord::Migration[4.2]
  def change
    remove_column :entitybuilder_characters, :slug, :string
    remove_column :entitybuilder_characters, :race, :string
  end
end
