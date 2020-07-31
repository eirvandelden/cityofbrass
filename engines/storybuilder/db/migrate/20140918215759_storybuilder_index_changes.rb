# frozen_string_literal: false

class StorybuilderIndexChanges < ActiveRecord::Migration
  def change
    remove_index :storybuilder_adventures, :privacy
    remove_index :storybuilder_adventures, [:resident_id, :slug]
    add_index :storybuilder_adventures, :resident_id
    add_index :storybuilder_adventures, :parent_id

    remove_index :storybuilder_pages, [:type, :privacy]
    add_index :storybuilder_pages, :resident_id
    add_index :storybuilder_pages, :parent_id

    add_index :storybuilder_menu_item_joins, :menu_item_id
  end
end
