class AddToolkitMenuToResident < ActiveRecord::Migration[4.2]
  def change
    add_column :residents, :toolkit_menu, :string
  end
end
