require "test_helper"
require Rails.root.join("db/migrate/20260908173331_backfill_gallery_active_storage_attachments")

class BackfillGalleryActiveStorageAttachmentsTest < ActiveSupport::TestCase
  setup do
    @written_files = []
  end

  teardown do
    @written_files.each { |file| FileUtils.rm_rf(file) }
  end

  test "attaches the legacy original file to a faq image" do
    id = insert_legacy_image("Gallery::FaqImage")
    write_legacy_file(legacy_path("faq-images", id))

    BackfillGalleryActiveStorageAttachments.new.up

    image = Gallery::FaqImage.find(id)
    assert image.file.attached?
    assert_equal sample_file_bytes, image.file.download
  end

  test "running the backfill twice does not create a duplicate attachment" do
    id = insert_legacy_image("Gallery::StockImage")
    write_legacy_file(legacy_path("stock-images", id))

    BackfillGalleryActiveStorageAttachments.new.up
    BackfillGalleryActiveStorageAttachments.new.up

    attachments = ActiveStorage::Attachment.where(record_type: "Gallery::Image", record_id: id, name: "file")
    assert_equal 1, attachments.count
  end

  test "raises when a legacy record's disk file is missing, but still backfills the others first" do
    missing_id = insert_legacy_image("Gallery::MapImage")
    present_id = insert_legacy_image("Gallery::MapImage")
    write_legacy_file(legacy_path("map-images", present_id))

    error = assert_raises(RuntimeError) do
      BackfillGalleryActiveStorageAttachments.new.up
    end
    assert_match(/1 row\(s\) skipped/, error.message)

    assert_not Gallery::MapImage.find(missing_id).file.attached?
    assert Gallery::MapImage.find(present_id).file.attached?
  end

  test "raises when attaching a record errors unexpectedly, but still backfills the others first" do
    broken_id = insert_legacy_image("Gallery::MapImage")
    present_id = insert_legacy_image("Gallery::MapImage")
    FileUtils.mkdir_p(legacy_path("map-images", broken_id))
    @written_files << legacy_path("map-images", broken_id)
    write_legacy_file(legacy_path("map-images", present_id))

    error = assert_raises(RuntimeError) do
      BackfillGalleryActiveStorageAttachments.new.up
    end
    assert_match(/1 row\(s\) errored/, error.message)

    assert_not Gallery::MapImage.find(broken_id).file.attached?
    assert Gallery::MapImage.find(present_id).file.attached?
  end

  test "reports progress as it runs, so a live db:migrate log shows more than silence" do
    id = insert_legacy_image("Gallery::FaqImage")
    write_legacy_file(legacy_path("faq-images", id))

    output, = capture_io { BackfillGalleryActiveStorageAttachments.new.up }

    assert_match(/Backfilling 1 Gallery::FaqImage images/, output)
    assert_match(/Done\. attached=1 skipped=0 errored=0/, output)
  end

  test "attaches the legacy original file to a resident image using the sharded path" do
    resident_id = residents(:razune).id
    id = insert_legacy_image("Gallery::ResidentImage", resident_id: resident_id)
    part_id = resident_id[0, 3].chars
    write_legacy_file(
      Rails.root.join("storage", "paperclip", "gallery", "residents", *part_id, resident_id, "images", id, "original.png")
    )

    BackfillGalleryActiveStorageAttachments.new.up

    image = Gallery::ResidentImage.find(id)
    assert image.file.attached?
    assert_equal sample_file_bytes, image.file.download
  end

  private
    def insert_legacy_image(type, resident_id: nil)
      id = SecureRandom.uuid
      connection.execute(<<~SQL)
        INSERT INTO gallery_images (id, type, name, resident_id, file_file_name, file_content_type, file_file_size, created_at, updated_at)
        VALUES (
          #{connection.quote(id)},
          #{connection.quote(type)},
          'Legacy image',
          #{connection.quote(resident_id)},
          'sample.png',
          'image/png',
          #{sample_file_bytes.bytesize},
          CURRENT_TIMESTAMP,
          CURRENT_TIMESTAMP
        )
      SQL
      id
    end

    def legacy_path(path_segment, id)
      Rails.root.join("storage", "paperclip", "gallery", path_segment, id, "original.png")
    end

    def write_legacy_file(path)
      FileUtils.mkdir_p(path.dirname)
      File.binwrite(path, sample_file_bytes)
      @written_files << path
    end

    def sample_file_bytes
      @sample_file_bytes ||= File.binread(Rails.root.join("test/fixtures/files/sample.png"))
    end

    def connection
      ActiveRecord::Base.connection
    end
end
