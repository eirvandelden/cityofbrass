class RemoveTypeIndexFromPages < ActiveRecord::Migration[4.2]
  def change
    remove_index :worldbuilder_pages, [ :district_id, :type, :slug ]
    add_index :worldbuilder_pages, [ :district_id, :slug ]
  end
end
