module Importer
  class Preview < ApplicationRecord
    RESIDENT_CONTENT = "resident_content"
    ADMIN_STOCK = "admin_stock"
    GAME_MASTER_5_XML = "game_master_5_xml"
    MODES = [ RESIDENT_CONTENT, ADMIN_STOCK ].freeze
    STATUSES = %w[parsing ready expired].freeze

    belongs_to :resident, optional: true
    has_many :preview_files, dependent: :destroy
    has_one :import, dependent: :nullify

    scope :admin_stock, -> { where(mode: ADMIN_STOCK) }
    scope :resident_content, -> { where(mode: RESIDENT_CONTENT) }

    validates :mode, presence: true
    validates :source, presence: true
    validates :status, presence: true
    validate :valid_mode
    validate :valid_status
    validate :resident_required_for_resident_content

    def add_uploads(files)
      uploads = Array(files).compact
      return missing_uploads unless uploads.any?

      transaction do
        uploads.each { |file| add_upload(file) }
        update!(status: "ready")
      end

      true
    end

    private

    def missing_uploads
      errors.add(:base, :missing_files)
      false
    end

    def add_upload(file)
      detector = Sources::GameMaster5Xml::Detector.new(file_io(file))
      preview_files.create!(
        file: file,
        detected_kind: detector.kind,
        entity_counts: detector.entity_counts,
        parse_errors: []
      )
    end

    def file_io(file)
      file.respond_to?(:tempfile) ? file.tempfile : file
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
