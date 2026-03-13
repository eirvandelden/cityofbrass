class AddTagsToWorldbuilderPages < ActiveRecord::Migration
  def change
    add_column :worldbuilder_pages, :tags, :text, array: true, default: []
    add_index  :worldbuilder_pages, :tags, using: 'gin'
  end
end
