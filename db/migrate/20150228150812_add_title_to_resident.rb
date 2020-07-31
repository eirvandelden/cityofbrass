# frozen_string_literal: false

class AddTitleToResident < ActiveRecord::Migration
  def change
    add_column :residents, :title, :string
  end
end
