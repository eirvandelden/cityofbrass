# Repair command for ActiveStorage attachments on gallery pictures still on legacy Paperclip storage.
# The backfill runs automatically during db:migrate via BackfillGalleryActiveStorageAttachments.
# Run this task only to repair missing attachments after a failed migration or data incident.
# Idempotent: skips gallery images that already have an ActiveStorage attachment.
# Run: bin/rails gallery:backfill_attachments
namespace :gallery do
  desc "Backfill ActiveStorage attachments for gallery pictures still on legacy Paperclip storage"
  task backfill_attachments: :environment do
    require Rails.root.join("db/migrate/20260908173331_backfill_gallery_active_storage_attachments")

    stats = BackfillGalleryActiveStorageAttachments.new.up

    puts "\nDone. attached=#{stats[:attached]} skipped=#{stats[:skipped]} errored=#{stats[:errored]}"
  end
end
