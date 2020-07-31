# frozen_string_literal: false

class DropEntitybuilderTraitsAndSpecialAbilities < ActiveRecord::Migration
  def change
    drop_table :entitybuilder_traits
    drop_table :entitybuilder_special_abilities
  end
end
