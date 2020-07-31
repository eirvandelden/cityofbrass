# frozen_string_literal: false

class RemoveTypeIndexFromPages < ActiveRecord::Migration
  def change
    remove_index :worldbuilder_pages, [:district_id, :type, :slug]
    add_index :worldbuilder_pages, [:district_id, :slug]
  end
end
