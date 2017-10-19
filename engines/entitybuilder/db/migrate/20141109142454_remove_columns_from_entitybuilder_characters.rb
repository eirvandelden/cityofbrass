class RemoveColumnsFromEntitybuilderCharacters < ActiveRecord::Migration
  def change
    remove_column :entitybuilder_characters, :slug, :string
    remove_column :entitybuilder_characters, :race, :string
  end
end
