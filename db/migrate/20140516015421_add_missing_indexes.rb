class AddMissingIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :affiliations, [:affiliate_id, :resident_id]
    add_index :affiliations, :affiliate_id
  end
end
