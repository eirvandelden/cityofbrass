class BackfillGalleryActiveStorageAttachments < ActiveRecord::Migration[8.1]
  # Gallery pictures are Single Table Inheritance subclasses of Gallery::Image, so the polymorphic
  # `record_type` ActiveStorage writes for their `file` attachment is always the shared base class name,
  # never the specific subtype — e.g. Gallery::FaqImage.polymorphic_name == "Gallery::Image". Every
  # attachment we create here has to use that same base class name to be found by the app.
  ATTACHMENT_RECORD_TYPE = "Gallery::Image".freeze

  LEGACY_PATH_SEGMENTS = {
    "Gallery::FaqImage" => "faq-images",
    "Gallery::StockImage" => "stock-images",
    "Gallery::MapImage" => "map-images"
  }.freeze

  def up
    stats = Hash.new(0)

    LEGACY_PATH_SEGMENTS.each do |sti_type, path_segment|
      pending_gallery_images(sti_type).each do |row|
        attach_original(stats, record_id: row["id"], disk_path: gallery_image_path(path_segment, row),
          filename: row["file_file_name"], content_type: row["file_content_type"])
      end
    end

    pending_resident_images.each do |row|
      attach_original(stats, record_id: row["id"], disk_path: resident_image_path(row),
        filename: row["file_file_name"], content_type: row["file_content_type"])
    end

    stats
  end

  def down
    # Intentionally does nothing — do not delete real image data on rollback.
    # Re-run via `bin/rails gallery:backfill_attachments` instead.
  end

  private
    def pending_gallery_images(sti_type)
      select_all(<<~SQL)
        SELECT id, file_file_name, file_content_type
        FROM gallery_images
        WHERE type = #{quote(sti_type)}
          AND file_file_name IS NOT NULL
          AND file_file_name != ''
          AND NOT EXISTS (
            SELECT 1 FROM active_storage_attachments asa
            WHERE asa.record_type = #{quote(ATTACHMENT_RECORD_TYPE)}
              AND asa.record_id = gallery_images.id
              AND asa.name = 'file'
          )
      SQL
    end

    def pending_resident_images
      select_all(<<~SQL)
        SELECT id, resident_id, file_file_name, file_content_type
        FROM gallery_images
        WHERE type = 'Gallery::ResidentImage'
          AND file_file_name IS NOT NULL
          AND file_file_name != ''
          AND resident_id IS NOT NULL
          AND NOT EXISTS (
            SELECT 1 FROM active_storage_attachments asa
            WHERE asa.record_type = #{quote(ATTACHMENT_RECORD_TYPE)}
              AND asa.record_id = gallery_images.id
              AND asa.name = 'file'
          )
      SQL
    end

    def gallery_image_path(path_segment, row)
      legacy_storage_root.join("gallery", path_segment, row["id"], "original.#{extension_for(row['file_file_name'])}")
    end

    def resident_image_path(row)
      resident_id = row["resident_id"]
      part_id = resident_id[0, 3].chars
      legacy_storage_root.join("gallery", "residents", *part_id, resident_id, "images", row["id"],
        "original.#{extension_for(row['file_file_name'])}")
    end

    def legacy_storage_root
      Rails.root.join("storage", "paperclip")
    end

    def extension_for(file_file_name)
      File.extname(file_file_name.to_s).delete_prefix(".")
    end

    def attach_original(stats, record_id:, disk_path:, filename:, content_type:)
      unless File.exist?(disk_path)
        puts "  SKIP id=#{record_id}: missing file at #{disk_path}"
        stats[:skipped] += 1
        return
      end

      blob = File.open(disk_path) do |file|
        ActiveStorage::Blob.create_and_upload!(io: file, filename: filename,
          content_type: content_type.presence || "application/octet-stream")
      end

      ActiveStorage::Attachment.create!(name: "file", record_type: ATTACHMENT_RECORD_TYPE, record_id: record_id, blob: blob)
      stats[:attached] += 1
    rescue => e
      puts "  ERROR id=#{record_id}: #{e.message}"
      stats[:errored] += 1
    end
end
