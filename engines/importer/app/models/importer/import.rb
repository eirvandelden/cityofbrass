module Importer
  class Import < ApplicationRecord
    include Processing

    RESIDENT_CONTENT = "resident_content"
    ADMIN_STOCK = "admin_stock"
    GAME_MASTER_5_XML = "game_master_5_xml"
    QUEUED = "queued"
    MODES = [ RESIDENT_CONTENT, ADMIN_STOCK ].freeze
    STATUSES = %w[queued running succeeded partial failed].freeze

    belongs_to :resident, optional: true
    belongs_to :preview, optional: true
    has_many :import_files, dependent: :destroy
    has_many :import_results, through: :import_files

    scope :admin_stock, -> { where(mode: ADMIN_STOCK) }
    scope :resident_content, -> { where(mode: RESIDENT_CONTENT) }

    validates :mode, presence: true
    validates :source, presence: true
    validates :status, presence: true
    validate :valid_mode
    validate :valid_status
    validate :resident_required_for_resident_content

    def source_file_rows
      source_files.map do |file|
        {
          name: file.file_file_name,
          kind: file.kind,
          status: source_file_status(file),
          counts: source_file_counts(file)
        }
      end
    end

    private

    def source_files
      return import_files if import_files.exists?

      preview&.preview_files || PreviewFile.none
    end

    def source_file_status(file)
      return file.parse_status if file.respond_to?(:parse_status)

      status
    end

    def source_file_counts(file)
      return {} unless file.respond_to?(:entity_counts)

      file.entity_counts.to_h
    end

    def valid_mode
      errors.add(:mode, "is not valid") if mode.present? && MODES.exclude?(mode)
    end

    def valid_status
      errors.add(:status, "is not valid") if status.present? && STATUSES.exclude?(status)
    end

    def resident_required_for_resident_content
      errors.add(:resident, "can't be blank") if mode == RESIDENT_CONTENT && resident.blank?
    end
  end
end
