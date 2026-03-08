# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2015_05_09_135307) do

  create_table "gallery_image_joins", id: :string, force: :cascade do |t|
    t.string "image_id", null: false
    t.string "imageable_id", null: false
    t.string "imageable_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["imageable_id", "imageable_type"], name: "index_gallery_image_joins_on_imageable_id_and_imageable_type"
  end

  create_table "gallery_images", id: :string, force: :cascade do |t|
    t.string "type", null: false
    t.string "resident_id"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.boolean "file_processing"
    t.index ["resident_id"], name: "index_gallery_images_on_resident_id"
  end

end
