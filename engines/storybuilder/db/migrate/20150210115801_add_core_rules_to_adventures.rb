# frozen_string_literal: false

class AddCoreRulesToAdventures < ActiveRecord::Migration
  def change
    add_column :storybuilder_adventures, :core_rules, :string
  end
end
