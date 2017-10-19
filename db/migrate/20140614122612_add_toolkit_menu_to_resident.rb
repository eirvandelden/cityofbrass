class AddToolkitMenuToResident < ActiveRecord::Migration
  def change
    add_column :residents, :toolkit_menu, :string
  end
end
