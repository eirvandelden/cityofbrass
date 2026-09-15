require "test_helper"

class GalleryStockImageUploadTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "anyone can view a stock picture after an administrator uploads it" do
    sign_in users(:dan)
    sign_in admins(:dan)
    upload = Rack::Test::UploadedFile.new(
      Gallery::Engine.root.join("app/assets/images/gallery/blank_image.png"), "image/png"
    )

    post gallery.stock_images_path, params: { stock_image: { name: "Uploaded stock picture", file: upload } }
    image = Gallery::StockImage.find_by!(name: "Uploaded stock picture")

    get gallery.stock_image_path(image)

    assert_response :success

    picture_src = css_select("#originalLabel + input")[0]["value"]

    # Sign out of both scopes on purpose: stock pictures are publicly readable, unlike FAQ pictures.
    sign_out :user
    sign_out :admin
    get picture_src

    assert_response :success
    assert_equal upload.read, response.body
    assert_includes response.headers["Cache-Control"], "public"
  end

  test "an unrecognized picture size returns not found instead of crashing" do
    sign_in users(:dan)
    sign_in admins(:dan)
    upload = Rack::Test::UploadedFile.new(
      Gallery::Engine.root.join("app/assets/images/gallery/blank_image.png"), "image/png"
    )
    post gallery.stock_images_path, params: { stock_image: { name: "Odd-sized stock picture", file: upload } }
    image = Gallery::StockImage.find_by!(name: "Odd-sized stock picture")
    sign_out :user
    sign_out :admin

    get "/attachments/gallery/stock_images/#{image.id}/not-a-real-style"

    assert_response :not_found
  end

  test "a corrupted picture returns not found instead of crashing when its thumbnail is requested" do
    image = Gallery::StockImage.new(name: "Corrupted stock picture")
    image.file.attach(io: StringIO.new("not a real image"), filename: "big.png", content_type: "image/png")
    image.save(validate: false)

    get "/attachments/gallery/stock_images/#{image.id}/thumb"

    assert_response :not_found
  end

  test "a picture whose stored file was deleted returns not found instead of crashing" do
    image = Gallery::StockImage.create!(name: "Stock picture with a missing file", file: sample_picture)
    image.file.blob.service.delete(image.file.blob.key)

    get "/attachments/gallery/stock_images/#{image.id}/original"

    assert_response :not_found

    get "/attachments/gallery/stock_images/#{image.id}/thumb"

    assert_response :not_found
  end

  private

  def sample_picture
    { io: File.open(Gallery::Engine.root.join("app/assets/images/gallery/blank_image.png")), filename: "sample.png", content_type: "image/png" }
  end
end
