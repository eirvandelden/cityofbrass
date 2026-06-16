class RemoveToolkitMenuFromResident < ActiveRecord::Migration[4.2]
  def change
    remove_column :residents, :toolkit_menu, :string
  end
end
