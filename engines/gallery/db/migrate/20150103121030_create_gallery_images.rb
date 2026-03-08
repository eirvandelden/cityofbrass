class CreateGalleryImages < ActiveRecord::Migration[4.2]
  def change
    create_table :gallery_images, id: :string do |t|
      t.string :type, null: false
      t.string :resident_id, null: false
      t.string :name

      t.timestamps
    end

    add_column :gallery_images, :file_file_name, :string
    add_column :gallery_images, :file_content_type, :string
    add_column :gallery_images, :file_file_size, :bigint
    add_column :gallery_images, :file_updated_at, :datetime
    add_index :gallery_images, :resident_id
  end
end
