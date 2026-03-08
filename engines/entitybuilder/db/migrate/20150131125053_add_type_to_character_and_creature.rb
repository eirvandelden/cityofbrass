class AddTypeToCharacterAndCreature < ActiveRecord::Migration[4.2]
  def change
    add_column :entitybuilder_characters, :type, :string
    add_column :entitybuilder_creatures, :type, :string
  end
end
