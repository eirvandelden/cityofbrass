class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

  before_create :assign_uuid_if_missing

  private

  # Skip integer PKs (auto-increment); allow :string, :uuid, and any other
  # string-like column that doesn't match Rails' integer type patterns.
  INTEGER_PK_TYPES = %i[integer bigint].freeze

  def assign_uuid_if_missing
    pk = self.class.primary_key
    col = self.class.columns_hash[pk.to_s]
    return unless col
    return if INTEGER_PK_TYPES.include?(col.type)

    current = self[pk]
    return if current.is_a?(String) && current.match?(UUID_PATTERN)

    self[pk] = SecureRandom.uuid
  end
end
