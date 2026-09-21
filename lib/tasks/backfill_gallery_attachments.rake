# Repair command for ActiveStorage attachments on gallery pictures still on legacy Paperclip storage.
# The backfill runs automatically during db:migrate via BackfillGalleryActiveStorageAttachments.
# Run this task only to repair missing attachments after a failed migration or data incident.
# Idempotent: skips gallery images that already have an ActiveStorage attachment.
# If a previous run was interrupted mid-backfill (killed, out of memory, cancelled deploy), a blob can
# be uploaded without its attachment ever being created — the idempotency check only looks at
# active_storage_attachments, so a re-run uploads a second blob for that row and the first is orphaned
# for good (this app has no unattached-blob purge job). Check ActiveStorage::Blob.unattached for
# orphans after an interrupted run and purge them by hand.
# Run: bin/rails gallery:backfill_attachments
namespace :gallery do
  desc "Backfill ActiveStorage attachments for gallery pictures still on legacy Paperclip storage"
  task backfill_attachments: :environment do
    require Rails.root.join("db/migrate/20260908173331_backfill_gallery_active_storage_attachments")

    BackfillGalleryActiveStorageAttachments.new.up
  end
end
