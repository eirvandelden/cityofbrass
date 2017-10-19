class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :affiliations, [:affiliate_id, :resident_id]
    add_index :affiliations, :affiliate_id
  end
end
