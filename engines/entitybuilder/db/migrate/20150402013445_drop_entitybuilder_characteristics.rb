# frozen_string_literal: false

class DropEntitybuilderCharacteristics < ActiveRecord::Migration
  def change
    drop_table :entitybuilder_characteristics
  end
end
