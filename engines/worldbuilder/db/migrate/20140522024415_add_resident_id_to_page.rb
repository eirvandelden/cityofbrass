class AddResidentIdToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :worldbuilder_pages, :resident_id, :string
  end
end
