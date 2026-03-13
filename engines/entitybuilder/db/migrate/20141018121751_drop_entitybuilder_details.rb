class DropEntitybuilderDetails < ActiveRecord::Migration
  def change
    drop_table :entitybuilder_details
  end
end
