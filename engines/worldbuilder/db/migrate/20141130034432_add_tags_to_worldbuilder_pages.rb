class AddTagsToWorldbuilderPages < ActiveRecord::Migration[4.2]
  def change
    add_column :worldbuilder_pages, :tags, :text
    add_index  :worldbuilder_pages, :tags, using: 'gin'
  end
end
