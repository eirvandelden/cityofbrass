require "test_helper"

class GalleryResidentImageUploadTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "the owner views their own resident picture after uploading it, a stranger cannot" do
    sign_in users(:dan)
    upload = Rack::Test::UploadedFile.new(
      Gallery::Engine.root.join("app/assets/images/gallery/blank_image.png"), "image/png"
    )

    post gallery.resident_images_path,
      params: { resident_image: { name: "Uploaded resident picture", resident_id: residents(:razune).id, file: upload } }
    image = Gallery::ResidentImage.find_by!(name: "Uploaded resident picture")

    get gallery.resident_image_path(image)
    assert_response :success

    picture_src = css_select("#originalLabel + input")[0]["value"]
    get picture_src

    assert_response :success
    assert_equal upload.read, response.body

    sign_out :user
    sign_in users(:lucas)
    get picture_src

    assert_response :forbidden
  end
end
