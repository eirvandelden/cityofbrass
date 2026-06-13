module Importer
  class ImportResult < ApplicationRecord
    OUTCOMES = %w[created skipped failed].freeze

    belongs_to :import_file
    belongs_to :record, polymorphic: true, optional: true

    scope :created, -> { where(outcome: "created") }
    scope :skipped, -> { where(outcome: "skipped") }
    scope :failed, -> { where(outcome: "failed") }

    validates :entity_type, presence: true
    validates :entity_name, presence: true
    validates :outcome, presence: true
    validate :valid_outcome

    private

    def valid_outcome
      errors.add(:outcome, :invalid) if outcome.present? && OUTCOMES.exclude?(outcome)
    end
  end
end
