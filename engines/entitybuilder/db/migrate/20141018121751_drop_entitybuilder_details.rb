class DropEntitybuilderDetails < ActiveRecord::Migration[4.2]
  def change
    drop_table :entitybuilder_details
  end
end
