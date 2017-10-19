class CreateGalleryImageJoins < ActiveRecord::Migration
  def change
    create_table :gallery_image_joins, id: :uuid do |t|
      t.uuid :image_id, :null => false
      t.uuid :imageable_id, :null => false
      t.string :imageable_type, :null => false

      t.timestamps
    end

    add_index :gallery_image_joins, [:imageable_id, :imageable_type]
  end
end
