require "test_helper"

# AttachmentFilesController pattern-matches the requested path into exactly four segments and
# never touches a raw filesystem path, so path traversal cannot apply the way it did to the old
# Paperclip-backed controller. These tests assert the equivalent safety property on the new
# controller: garbage input to /attachments/* cleanly 404s.
class AttachmentFilesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "an unknown record id 404s" do
    get attachment_file_path("gallery/faq_images/00000000-0000-0000-0000-000000000000/original")

    assert_response :not_found
  end

  test "an unrecognized collection segment 404s" do
    get attachment_file_path("gallery/unknown_things/some-id/original")

    assert_response :not_found
  end

  test "a record whose file is not attached 404s" do
    sign_in admins(:dan)
    id = insert_faq_image_without_a_file

    get attachment_file_path("gallery/faq_images/#{id}/original")

    assert_response :not_found
  end

  private
    def insert_faq_image_without_a_file
      id = SecureRandom.uuid
      connection = ActiveRecord::Base.connection
      connection.execute(<<~SQL)
        INSERT INTO gallery_images (id, type, name, created_at, updated_at)
        VALUES (
          #{connection.quote(id)},
          'Gallery::FaqImage',
          'No file attached',
          CURRENT_TIMESTAMP,
          CURRENT_TIMESTAMP
        )
      SQL
      id
    end
end
