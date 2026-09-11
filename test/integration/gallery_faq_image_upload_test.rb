require "test_helper"

class GalleryFaqImageUploadTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "an administrator views a help picture after uploading it" do
    sign_in users(:dan)
    sign_in admins(:dan)
    upload = Rack::Test::UploadedFile.new(
      Gallery::Engine.root.join("app/assets/images/gallery/blank_image.png"), "image/png"
    )

    post gallery.faq_images_path, params: { faq_image: { name: "Uploaded help picture", file: upload } }
    image = Gallery::FaqImage.find_by!(name: "Uploaded help picture")

    get gallery.faq_image_path(image)
    assert_response :success

    picture_src = css_select("#originalLabel + input")[0]["value"]
    get picture_src

    assert_response :success
    assert_equal upload.read, response.body
  end

  test "an administrator sees a resized thumbnail of the help picture" do
    sign_in users(:dan)
    sign_in admins(:dan)
    upload = Rack::Test::UploadedFile.new(
      Gallery::Engine.root.join("app/assets/images/gallery/blank_image.png"), "image/png"
    )

    post gallery.faq_images_path, params: { faq_image: { name: "Thumbnailed help picture", file: upload } }
    image = Gallery::FaqImage.find_by!(name: "Thumbnailed help picture")

    get gallery.faq_image_path(image)
    thumb_src = css_select("#thumbLabel + input")[0]["value"]
    get thumb_src

    assert_response :success
    assert_not_equal upload.read, response.body
  end

  test "a non-admin cannot view a help picture" do
    sign_in users(:dan)
    sign_in admins(:dan)
    upload = Rack::Test::UploadedFile.new(
      Gallery::Engine.root.join("app/assets/images/gallery/blank_image.png"), "image/png"
    )

    post gallery.faq_images_path, params: { faq_image: { name: "Restricted help picture", file: upload } }
    image = Gallery::FaqImage.find_by!(name: "Restricted help picture")

    get gallery.faq_image_path(image)
    picture_src = css_select("#originalLabel + input")[0]["value"]

    sign_out :admin
    sign_out :user
    sign_in users(:lucas)
    get picture_src

    assert_response :forbidden
  end
end
