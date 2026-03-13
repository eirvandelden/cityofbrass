class AddTypeToCharacterAndCreature < ActiveRecord::Migration
  def change
    add_column :entitybuilder_characters, :type, :string
    add_column :entitybuilder_creatures, :type, :string
  end
end
