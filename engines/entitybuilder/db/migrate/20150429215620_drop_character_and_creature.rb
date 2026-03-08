class DropCharacterAndCreature < ActiveRecord::Migration[4.2]
  def change
    drop_table :entitybuilder_characters
    drop_table :entitybuilder_creatures
  end
end
