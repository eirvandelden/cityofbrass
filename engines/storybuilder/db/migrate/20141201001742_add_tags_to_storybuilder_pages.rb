class AddTagsToStorybuilderPages < ActiveRecord::Migration[4.2]
  def change
    add_column :storybuilder_pages, :tags, :text
    add_index  :storybuilder_pages, :tags, using: 'gin'
  end
end
