class AddTypeIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :entitybuilder_characters, :type
    add_index :entitybuilder_creatures, :type
  end
end
