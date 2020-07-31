# frozen_string_literal: false

class DropCharacterAndCreature < ActiveRecord::Migration
  def change
    drop_table :entitybuilder_characters
    drop_table :entitybuilder_creatures
  end
end
