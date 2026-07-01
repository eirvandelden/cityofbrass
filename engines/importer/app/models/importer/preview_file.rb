module Importer
  class PreviewFile < ApplicationRecord
    KINDS = %w[campaign compendium characters pc unsupported].freeze

    belongs_to :preview

    has_attached_file :file,
      path: ":rails_root/storage/paperclip/importer/previews/:id/:filename",
      url: "/paperclip/importer/previews/:id/:filename"

    validates :detected_kind, presence: true
    validate :valid_detected_kind
    validate :valid_override_kind
    validates_attachment_content_type :file, content_type: %w[application/xml text/xml text/plain]

    def kind
      override_kind.presence || detected_kind
    end

    private

    def valid_detected_kind
      errors.add(:detected_kind, :invalid) if detected_kind.present? && KINDS.exclude?(detected_kind)
    end

    def valid_override_kind
      errors.add(:override_kind, :invalid) if override_kind.present? && KINDS.exclude?(override_kind)
    end
  end
end
