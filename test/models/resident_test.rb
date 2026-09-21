require 'test_helper'

class ResidentTest < ActiveSupport::TestCase

  test "should have the necessary required validators" do
    resident = Resident.new(name: "TestResident")
    assert_not resident.valid?
    assert_equal [:user, :user_id], resident.errors.attribute_names
  end

  test "resident_images_sum reflects the actual stored size of attached pictures" do
    resident = residents(:razune)
    file = { io: File.open(Rails.root.join("test/fixtures/files/sample.png")),
             filename: "sample.png", content_type: "image/png" }
    picture = Gallery::ResidentImage.create!(name: "Portrait", resident: resident, file: file)

    expected_kb = (picture.file.blob.byte_size / 1000.0).round(1)

    assert_equal "#{expected_kb} KB", resident.resident_images_sum
  end

end
