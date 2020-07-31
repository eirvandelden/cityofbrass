# frozen_string_literal: false

class AddResidentIdIndexToCharacters < ActiveRecord::Migration
  def change
    add_index :entitybuilder_characters, :resident_id
  end
end
