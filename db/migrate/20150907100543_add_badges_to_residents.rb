# frozen_string_literal: false

class AddBadgesToResidents < ActiveRecord::Migration
  def change
    add_column :residents, :badges, :text
  end
end
