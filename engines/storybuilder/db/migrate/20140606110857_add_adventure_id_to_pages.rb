class AddAdventureIdToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :storybuilder_pages, :adventure_id, :string
    add_index :storybuilder_pages, [ :adventure_id, :type, :slug ]
  end
end
