class WbAddSortWeightToPage < ActiveRecord::Migration
  def change
    add_column :worldbuilder_pages, :sort_weight, :integer, default: 1000, :null => false
  end
end
