require "nokogiri"

module Importer
  class Preview < ApplicationRecord
    RESIDENT_CONTENT = "resident_content"
    ADMIN_STOCK = "admin_stock"
    GAME_MASTER_5_XML = "game_master_5_xml"
    MODES = [ RESIDENT_CONTENT, ADMIN_STOCK ].freeze
    STATUSES = %w[parsing ready expired].freeze
    XML_CONTENT_TYPES = %w[application/xml text/xml].freeze
    PLAIN_TEXT_CONTENT_TYPE = "text/plain"

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
      return true if XML_CONTENT_TYPES.include?(upload_content_type(file))
      return false unless upload_content_type(file) == PLAIN_TEXT_CONTENT_TYPE

      valid_xml?(file_io(file))
    end

    def upload_content_type(file)
      file.content_type.to_s.split(";").first
    end

    def valid_xml?(io)
      Nokogiri::XML(io) { |config| config.strict.noblanks }
      true
    rescue Nokogiri::XML::SyntaxError
      false
    ensure
      io.rewind if io.respond_to?(:rewind)
    end

    def invalid_upload
      errors.add(:base, :invalid_file)
      false
    end

    def valid_mode
      errors.add(:mode, :invalid) if mode.present? && MODES.exclude?(mode)
    end

    def valid_status
      errors.add(:status, :invalid) if status.present? && STATUSES.exclude?(status)
    end

    def resident_required_for_resident_content
      errors.add(:resident, :blank) if mode == RESIDENT_CONTENT && resident.blank?
    end
  end
end
