# frozen_string_literal: false

class AddPageLabelToWorldbuilderDistricts < ActiveRecord::Migration
  def change
    add_column :worldbuilder_districts, :page_label, :string
  end
end
