require "application_system_test_case"

class GalleryUploadTest < ApplicationSystemTestCase
  setup do
    @file_definition = Gallery::ResidentImage.paperclip_definitions[:file].dup
    Gallery::ResidentImage.paperclip_definitions[:file][:path] = test_file_path
    Gallery::ResidentImage.paperclip_definitions[:file][:url] = test_file_url
  end

  teardown do
    Gallery::ResidentImage.paperclip_definitions[:file] = @file_definition
  end

  test "user uploads a resident image" do
    sign_in_as users(:dan), scope: :user

    assert_enqueued_jobs 1, only: DelayedPaperclip::ProcessJob do
      visit gallery.new_resident_image_path
      fill_in "Name", with: "System Test Image"
      attach_file "File", file_fixture("sample.png")
      click_button "Save"
    end

    image = Gallery::ResidentImage.find_by!(name: "System Test Image")

    assert_text "Image was successfully created."
    assert_text "System Test Image"
    assert image.file?
    assert image.file_processing?
  end

  private

  def test_file_path
    ":rails_root/public/system/gallery/residents/:part_id/:resident_id/images/:id/:style.:extension"
  end

  def test_file_url
    "/system/gallery/residents/:part_id/:resident_id/images/:id/:style.:extension"
  end
end
