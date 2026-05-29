module Importer
  class ImportFile < ApplicationRecord
    KINDS = PreviewFile::KINDS
    PARSE_STATUSES = %w[pending parsed failed].freeze

    belongs_to :import
    has_many :import_results, dependent: :destroy

    has_attached_file :file, path: "importer/imports/:id/:filename"

    validates :kind, presence: true
    validates :parse_status, presence: true
    validate :valid_kind
    validate :valid_parse_status
    validates_attachment_content_type :file, content_type: %w[application/xml text/xml]

    private

    def valid_kind
      errors.add(:kind, "is not valid") if kind.present? && KINDS.exclude?(kind)
    end

    def valid_parse_status
      errors.add(:parse_status, "is not valid") if parse_status.present? && PARSE_STATUSES.exclude?(parse_status)
    end
  end
end
