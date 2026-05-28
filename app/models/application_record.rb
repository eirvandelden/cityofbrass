class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

  before_create :assign_uuid_if_missing

  private

  def assign_uuid_if_missing
    pk = self.class.primary_key
    return unless self.class.columns_hash[pk.to_s]&.type == :string

    current = self[pk]
    return if current.is_a?(String) && current.match?(UUID_PATTERN)

    self[pk] = SecureRandom.uuid
  end
end
