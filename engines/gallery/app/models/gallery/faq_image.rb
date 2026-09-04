module Gallery
  class FaqImage < Image
    ALLOWED_CONTENT_TYPES = %w[image/jpeg image/jpg image/png image/gif]
    MAX_FILE_SIZE = 2.megabytes

    has_one_attached :file do |attachable|
      attachable.variant :thumb, resize_to_limit: [ 200, 200 ]
      attachable.variant :medium, resize_to_limit: [ 400, 400 ]
    end

    validates :file, presence: true
    validate :file_is_an_allowed_content_type
    validate :file_is_within_the_size_limit

    def file_attached?
      file.attached?
    end

    def file_url(style)
      Rails.application.routes.url_helpers.attachment_file_path("gallery/faq_images/#{id}/#{style}")
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

      errors.add(:file, "must be smaller than 2MB") if file.blob.byte_size > MAX_FILE_SIZE
    end
  end
end
