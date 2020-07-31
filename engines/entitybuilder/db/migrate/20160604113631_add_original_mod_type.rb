# frozen_string_literal: false

class AddOriginalModType < ActiveRecord::Migration
  def change
    add_column :entitybuilder_modifiers, :original_mod_type, :string
  end
end
