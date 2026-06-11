module Importer
  class Preview < ApplicationRecord
    RESIDENT_CONTENT = "resident_content"
    ADMIN_STOCK = "admin_stock"
    GAME_MASTER_5_XML = "game_master_5_xml"
    MAX_UPLOAD_SIZE = 10.megabytes
    MODES = [ RESIDENT_CONTENT, ADMIN_STOCK ].freeze
    STATUSES = %w[parsing ready expired].freeze
    XML_CONTENT_TYPES = %w[application/xml text/xml].freeze

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

      persisted = false
      transaction do
        uploads.each { |file| raise ActiveRecord::Rollback unless add_upload(file) }
        persisted = update!(status: "ready")
      end

      persisted
    end

    private

    def missing_uploads
      errors.add(:base, :missing_files)
      false
    end

    def add_upload(file)
      return invalid_upload unless xml_upload?(file)
      return oversized_upload if upload_size(file) > MAX_UPLOAD_SIZE

      detector = Sources::GameMaster5Xml::Detector.new(file_io(file))
      preview_files.create!(
        file: file,
        detected_kind: detector.kind,
        entity_counts: detector.entity_counts,
        parse_errors: []
      )

      true
    rescue ActiveRecord::RecordInvalid, ArgumentError
      invalid_upload
    end

    def file_io(file)
      file.respond_to?(:tempfile) ? file.tempfile : file
    end

    def xml_upload?(file)
      XML_CONTENT_TYPES.include?(upload_content_type(file))
    end

    def upload_content_type(file)
      file.content_type.to_s.split(";").first
    end

    def upload_size(file)
      return file.size if file.respond_to?(:size)
      return file.tempfile.size if file.respond_to?(:tempfile)

      0
    end

    def oversized_upload
      errors.add(:base, :file_too_large, max_size: ActiveSupport::NumberHelper.number_to_human_size(MAX_UPLOAD_SIZE))
      false
    end

    def invalid_upload
      errors.add(:base, :invalid_file)
      false
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
