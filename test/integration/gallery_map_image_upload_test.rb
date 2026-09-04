require "test_helper"

class GalleryMapImageUploadTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "anyone can view a map picture after an administrator uploads it" do
    sign_in users(:dan)
    sign_in admins(:dan)
    upload = Rack::Test::UploadedFile.new(
      Gallery::Engine.root.join("app/assets/images/gallery/blank_image.png"), "image/png"
    )

    post gallery.map_images_path, params: { map_image: { name: "Uploaded map picture", file: upload } }
    image = Gallery::MapImage.find_by!(name: "Uploaded map picture")

    get gallery.map_image_path(image)
    assert_response :success

    picture_src = css_select("#originalLabel + input")[0]["value"]

    # Sign out of both scopes on purpose: map pictures are publicly readable, unlike FAQ pictures.
    sign_out :user
    sign_out :admin
    get picture_src

    assert_response :success
    assert_equal upload.read, response.body
  end
end
