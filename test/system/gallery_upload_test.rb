require "application_system_test_case"

class GalleryUploadTest < ApplicationSystemTestCase
  setup do
    @file_definition = Gallery::ResidentImage.attachment_definitions[:file].dup
    Gallery::ResidentImage.attachment_definitions[:file][:path] = test_file_path
    Gallery::ResidentImage.attachment_definitions[:file][:url] = test_file_url
  end

  teardown do
    Gallery::ResidentImage.attachment_definitions[:file] = @file_definition
  end

  test "user uploads a resident image" do
    sign_in_as users(:dan), scope: :user

    visit gallery.new_resident_image_path
    fill_in "Name", with: "System Test Image"
    attach_file "File", file_fixture("sample.png")
    click_button "Save"

    assert_text "Image was successfully created."
    assert_text "System Test Image"
  end

  private

  def test_file_path
    ":rails_root/public/system/gallery/residents/:part_id/:resident_id/images/:id/:style.:extension"
  end

  def test_file_url
    "/system/gallery/residents/:part_id/:resident_id/images/:id/:style.:extension"
  end
end
