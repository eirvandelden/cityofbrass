require "application_system_test_case"

class GalleryUploadTest < ApplicationSystemTestCase
  test "user uploads a resident image" do
    sign_in_as users(:dan), scope: :user

    visit gallery.new_resident_image_path
    fill_in "Name", with: "System Test Image"
    attach_file "File", file_fixture("sample.png")
    click_button "Save"

    assert_text "Image was successfully created."
    assert_text "System Test Image"
  end
end
