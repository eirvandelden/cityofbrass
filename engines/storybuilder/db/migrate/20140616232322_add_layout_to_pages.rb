# frozen_string_literal: false

class AddLayoutToPages < ActiveRecord::Migration
  def change
    add_column :storybuilder_pages, :page_layout, :string
  end
end
