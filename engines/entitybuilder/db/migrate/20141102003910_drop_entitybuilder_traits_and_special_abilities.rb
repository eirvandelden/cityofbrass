class DropEntitybuilderTraitsAndSpecialAbilities < ActiveRecord::Migration[4.2]
  def change
    drop_table :entitybuilder_traits, if_exists: true
    drop_table :entitybuilder_special_abilities, if_exists: true
  end
end
