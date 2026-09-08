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

      errors.add(:file, "must be a JPEG, PNG or GIF") unless file.content_type.in?(ALLOWED_CONTENT_TYPES)
    end

    def file_is_within_the_size_limit
      return unless file.attached?

      errors.add(:file, "must be smaller than #{self.class.max_file_size / 1.megabyte}MB") if file.blob.byte_size > self.class.max_file_size
    end
  end
end
