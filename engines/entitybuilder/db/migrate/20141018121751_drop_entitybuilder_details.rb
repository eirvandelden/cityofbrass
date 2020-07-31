# frozen_string_literal: false

class DropEntitybuilderDetails < ActiveRecord::Migration
  def change
    drop_table :entitybuilder_details
  end
end
