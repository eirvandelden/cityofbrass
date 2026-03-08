class WbAddSortWeightToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :worldbuilder_pages, :sort_weight, :integer, default: 1000, null: false
  end
end
