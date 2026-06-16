class DropEntitybuilderCharacteristics < ActiveRecord::Migration[4.2]
  def change
    drop_table :entitybuilder_characteristics, if_exists: true
  end
end
