class AddTypeIndex < ActiveRecord::Migration
  def change
    add_index :entitybuilder_characters, :type
    add_index :entitybuilder_creatures, :type
  end
end
