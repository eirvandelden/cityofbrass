# frozen_string_literal: false

class AddResidentIdToPage < ActiveRecord::Migration
  def change
    add_column :worldbuilder_pages, :resident_id, :uuid
  end
end
