require "application_system_test_case"

class GalleryUploadTest < ApplicationSystemTestCase
  setup do
    @file_options = resident_image_file_options
    @file_definition = @file_options.dup
    @file_options[:path] = test_file_path
    @file_options[:url] = test_file_url
  end

  teardown do
    @file_options.clear
    @file_options.merge!(@file_definition)
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

  def resident_image_file_options
    Paperclip::AttachmentRegistry.each_definition do |klass, name, options|
      return options if klass == Gallery::ResidentImage && name == :file
    end

    raise "Missing Gallery::ResidentImage file attachment"
  end

  def test_file_path
    ":rails_root/public/system/gallery/residents/:part_id/:resident_id/images/:id/:style.:extension"
  end

  def test_file_url
    "/system/gallery/residents/:part_id/:resident_id/images/:id/:style.:extension"
  end
end
