# frozen_string_literal: false

class RemovePagesIndexResidentId < ActiveRecord::Migration
  def change
    remove_index :storybuilder_pages, [:resident_id, :type, :slug]
  end
end
