class AddTitleToResident < ActiveRecord::Migration[4.2]
  def change
    add_column :residents, :title, :string
  end
end
