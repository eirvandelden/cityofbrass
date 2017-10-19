class RemoveNotNullFromGalleryResidentId < ActiveRecord::Migration
  def change
    change_column_null(:gallery_images, :resident_id, true)
  end
end
