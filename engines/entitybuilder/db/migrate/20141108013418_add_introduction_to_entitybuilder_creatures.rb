# frozen_string_literal: false

class AddIntroductionToEntitybuilderCreatures < ActiveRecord::Migration
  def change
    add_column :entitybuilder_creatures, :introduction, :text
  end
end
