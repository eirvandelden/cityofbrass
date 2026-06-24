require "test_helper"

class ActiveStorageConfigurationTest < ActiveSupport::TestCase
  test "test environment stores active storage files with the test service" do
    assert_equal :test, Rails.application.config.active_storage.service
  end

  test "direct upload blobs get a service name" do
    blob = ActiveStorage::Blob.create_before_direct_upload!(
      filename: "example.txt",
      byte_size: 1,
      checksum: "DMF1ucDxtqgxw5niaXcmYQ==",
      content_type: "text/plain"
    )

    assert_equal "test", blob.service_name
  end

  test "image processing is available for action text image previews" do
    assert_nothing_raised { require "image_processing" }
  end
end
