class CreateGalleryImageJoins < ActiveRecord::Migration[4.2]
  def change
    create_table :gallery_image_joins, id: :string do |t|
      t.string :image_id, null: false
      t.string :imageable_id, null: false
      t.string :imageable_type, null: false

      t.timestamps
    end

    add_index :gallery_image_joins, [ :imageable_id, :imageable_type ]
  end
end
