class DropCharacterAndCreature < ActiveRecord::Migration[4.2]
  def change
    drop_table :entitybuilder_characters, if_exists: true
    drop_table :entitybuilder_creatures, if_exists: true
  end
end
