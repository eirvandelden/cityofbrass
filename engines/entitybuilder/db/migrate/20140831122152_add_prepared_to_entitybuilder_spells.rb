# frozen_string_literal: false

class AddPreparedToEntitybuilderSpells < ActiveRecord::Migration
  def change
    add_column :entitybuilder_spells, :prepared, :boolean
  end
end
