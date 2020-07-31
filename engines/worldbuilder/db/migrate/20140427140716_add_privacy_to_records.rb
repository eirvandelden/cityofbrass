# frozen_string_literal: false

class AddPrivacyToRecords < ActiveRecord::Migration
  def change
    remove_column :worldbuilder_districts, :privacy, :string
    add_column :worldbuilder_districts, :privacy, :string
  end
end
