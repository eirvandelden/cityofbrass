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
end
