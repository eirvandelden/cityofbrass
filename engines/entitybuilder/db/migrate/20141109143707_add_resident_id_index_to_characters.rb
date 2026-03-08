class AddResidentIdIndexToCharacters < ActiveRecord::Migration[4.2]
  def change
    add_index :entitybuilder_characters, :resident_id
  end
end
