class AddAdventureIdToPages < ActiveRecord::Migration
  def change
    add_column :storybuilder_pages, :adventure_id, :uuid
    add_index :storybuilder_pages, [:adventure_id, :type, :slug]
  end
end
