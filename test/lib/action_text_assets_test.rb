require "test_helper"

class ActionTextAssetsTest < ActiveSupport::TestCase
  test "application.js requires activestorage before trix" do
    source = Rails.root.join("app/assets/javascripts/application.js").read
    activestorage_pos = source.index("activestorage")
    trix_pos          = source.index("require trix")

    assert activestorage_pos, "application.js must require activestorage"
    assert trix_pos,          "application.js must require trix"
    assert activestorage_pos < trix_pos, "activestorage must be required before trix"
  end

  test "application.js requires actiontext/attachment_upload after trix" do
    source   = Rails.root.join("app/assets/javascripts/application.js").read
    trix_pos = source.index("require trix")
    upload_pos = source.index("actiontext/attachment_upload")

    assert upload_pos, "application.js must require actiontext/attachment_upload"
    assert trix_pos < upload_pos, "attachment_upload must be required after trix"
  end

  test "attachment_upload adapter listens for trix-attachment-add" do
    source = Rails.root.join("app/assets/javascripts/actiontext/attachment_upload.js").read
    assert_includes source, "trix-attachment-add"
  end

  test "attachment_upload adapter uses ActiveStorage.DirectUpload" do
    source = Rails.root.join("app/assets/javascripts/actiontext/attachment_upload.js").read
    assert_includes source, "ActiveStorage.DirectUpload"
  end
end
