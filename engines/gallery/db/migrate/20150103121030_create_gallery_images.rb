class CreateGalleryImages < ActiveRecord::Migration
  def change
    create_table :gallery_images, id: :uuid do |t|
      t.string :type, :null => false
      t.uuid :resident_id, :null => false
      t.string :name

      t.timestamps
    end

    add_attachment :gallery_images, :file
    add_index :gallery_images, :resident_id

  end
end
