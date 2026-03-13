class SbAddSortWeightToPage < ActiveRecord::Migration
  def change
    add_column :storybuilder_pages, :sort_weight, :integer, default: 1000, :null => false
  end
end
