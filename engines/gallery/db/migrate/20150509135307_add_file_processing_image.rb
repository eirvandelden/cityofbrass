class AddFileProcessingImage < ActiveRecord::Migration[4.2]
  def change
    add_column :gallery_images, :file_processing, :boolean
  end
end
