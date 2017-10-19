class RemoveToolkitMenuFromResident < ActiveRecord::Migration
  def change
    remove_column :residents, :toolkit_menu, :string
  end
end
