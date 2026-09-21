require "test_helper"

class ChangeActiveStorageAttachmentsRecordIdToStringTest < ActiveSupport::TestCase
  test "the widened record_id column holds both an integer-keyed and a UUID-keyed record id correctly" do
    rich_text = action_text_rich_texts(:message_message1_body)
    faq_image = Gallery::FaqImage.create!(name: "pin test", file: sample_upload)

    blob = ActiveStorage::Blob.create_and_upload!(io: File.open(sample_file_path), filename: "sample.png",
content_type: "image/png")

    integer_attachment = ActiveStorage::Attachment.create!(
      name: "embeds", record_type: "ActionText::RichText", record_id: rich_text.id, blob: blob
    )
    uuid_attachment = ActiveStorage::Attachment.create!(
      name: "pinned_file", record_type: "Gallery::Image", record_id: faq_image.id, blob: blob
    )

    assert_equal rich_text.id, ActiveStorage::Attachment.find(integer_attachment.id).record_id.to_i
    assert_equal faq_image.id, ActiveStorage::Attachment.find(uuid_attachment.id).record_id
    assert_equal [ integer_attachment ], rich_text.embeds.to_a
  end

  private

  def sample_file_path
    Rails.root.join("test/fixtures/files/sample.png")
  end

  def sample_upload
    { io: File.open(sample_file_path), filename: "sample.png", content_type: "image/png" }
  end
end
