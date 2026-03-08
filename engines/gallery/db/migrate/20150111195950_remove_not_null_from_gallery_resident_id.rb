class RemoveNotNullFromGalleryResidentId < ActiveRecord::Migration[4.2]
  def change
    change_column_null(:gallery_images, :resident_id, true)
  end
end
