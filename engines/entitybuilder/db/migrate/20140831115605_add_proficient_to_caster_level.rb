# frozen_string_literal: false

class AddProficientToCasterLevel < ActiveRecord::Migration
  def change
    add_column :entitybuilder_caster_levels, :proficient, :boolean
  end
end
