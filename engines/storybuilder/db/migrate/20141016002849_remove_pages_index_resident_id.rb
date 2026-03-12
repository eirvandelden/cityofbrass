class RemovePagesIndexResidentId < ActiveRecord::Migration[4.2]
  def change
    remove_index :storybuilder_pages, [ :resident_id, :type, :slug ]
  end
end
