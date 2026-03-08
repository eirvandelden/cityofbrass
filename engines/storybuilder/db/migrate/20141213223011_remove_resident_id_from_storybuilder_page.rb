class RemoveResidentIdFromStorybuilderPage < ActiveRecord::Migration[4.2]
  def change
    remove_column :storybuilder_pages, :resident_id, :string
    remove_column :storybuilder_pages, :page_layout, :string
  end
end
