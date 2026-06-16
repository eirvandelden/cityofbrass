class DropResourceTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :resources_image_joins
    drop_table :resources_images
  end
end
