# frozen_string_literal: false

class AddTagsToStorybuilderPages < ActiveRecord::Migration
  def change
    add_column :storybuilder_pages, :tags, :text, array: true, default: []
    add_index  :storybuilder_pages, :tags, using: 'gin'
  end
end
