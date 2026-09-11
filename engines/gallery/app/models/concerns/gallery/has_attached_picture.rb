module Gallery
  module HasAttachedPicture
    extend ActiveSupport::Concern

    ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/gif].freeze

    included do
      has_one_attached :file do |attachable|
        attachable.variant :thumb, resize_to_limit: [ 200, 200 ], preprocessed: true
        attachable.variant :medium, resize_to_limit: [ 400, 400 ], preprocessed: true
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
      segment = Gallery::Image::ATTACHMENT_SEGMENTS.key(self.class.name)
      Rails.application.routes.url_helpers.attachment_file_path("gallery/#{segment}/#{id}/#{style}")
    end

    def file_size
      return "0.0 KB" unless file.attached?

      Gallery::Image.format_byte_size(file.blob.byte_size)
    end

    private

    def file_is_an_allowed_content_type
      return unless attachment_changes["file"]

      errors.add(:file, "must be a JPEG, PNG or GIF") unless sniffed_content_type.in?(ALLOWED_CONTENT_TYPES)
    end

    # Sniffs the real bytes rather than trusting the declared content type: Marcel::MimeType.for
    # falls back to the declared type or the filename extension whenever it can't identify the
    # bytes by magic number, so passing name/declared_type here would let a mislabeled file through.
    def sniffed_content_type
      Marcel::MimeType.for(pending_attachable_io(attachment_changes["file"].attachable))
    end

    def pending_attachable_io(attachable)
      attachable.is_a?(Hash) ? attachable.fetch(:io) : attachable.open
    end

    def file_is_within_the_size_limit
      return unless attachment_changes["file"]

      return unless file.blob.byte_size > self.class.max_file_size

      errors.add(:file, "must be smaller than #{self.class.max_file_size / 1.megabyte}MB")
    end
  end
end
