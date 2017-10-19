class RemoveResidentIdFromStorybuilderPage < ActiveRecord::Migration
  def change
    remove_column :storybuilder_pages, :resident_id, :uuid
    remove_column :storybuilder_pages, :page_layout, :string
  end
end
