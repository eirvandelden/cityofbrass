class DropResourceTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :resources_image_joins, if_exists: true
    drop_table :resources_images, if_exists: true
  end
end
