module Gallery
  # Included per-model rather than placed on Gallery::Image so it never collided with
  # Gallery::ResidentImage's has_attached_file macro while that model was still on Paperclip.
  module HasAttachedPicture
    extend ActiveSupport::Concern

    ALLOWED_CONTENT_TYPES = %w[image/jpeg image/jpg image/png image/gif]

    included do
      has_one_attached :file do |attachable|
        attachable.variant :thumb, resize_to_limit: [ 200, 200 ]
        attachable.variant :medium, resize_to_limit: [ 400, 400 ]
      end

      validates :file, presence: true
      validate :file_is_an_allowed_content_type
      validate :file_is_within_the_size_limit
    end

    class_methods do
      def max_file_size
        2.megabytes
      end

      def total_byte_size
        joins(file_attachment: :blob).sum("active_storage_blobs.byte_size")
      end
    end

    def file_attached?
      file.attached?
    end

    def file_url(style)
      Rails.application.routes.url_helpers.attachment_file_path(
        "gallery/#{self.class.name.demodulize.underscore.pluralize}/#{id}/#{style}"
      )
    end

    def file_size
      return "0.0 KB" unless file.attached?

      size = file.blob.byte_size.to_f
      return "#{(size / 1_000_000).round(1)} MB" if size >= 1_000_000
      "#{(size / 1_000).round(1)} KB"
    end

    private

    def file_is_an_allowed_content_type
      return unless file.attached?

      errors.add(:file, "must be a JPEG, PNG or GIF") unless sniffed_content_type.in?(ALLOWED_CONTENT_TYPES)
    end

    # Sniffs the real bytes rather than trusting the declared content type: Marcel::MimeType.for
    # falls back to the declared type or the filename extension whenever it can't identify the
    # bytes by magic number, so passing name/declared_type here would let a mislabeled file through.
    def sniffed_content_type
      pending_upload = attachment_changes["file"]
      return Marcel::MimeType.for(pending_attachable_io(pending_upload.attachable)) if pending_upload

      file.blob.open { |io| Marcel::MimeType.for(io) }
    end

    def pending_attachable_io(attachable)
      attachable.is_a?(Hash) ? attachable.fetch(:io) : attachable.open
    end

    def file_is_within_the_size_limit
      return unless file.attached?

      errors.add(:file, "must be smaller than #{self.class.max_file_size / 1.megabyte}MB") if file.blob.byte_size > self.class.max_file_size
    end
  end
end
