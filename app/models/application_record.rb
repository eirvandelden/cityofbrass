class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  before_create :assign_uuid_if_blank

  private

  def assign_uuid_if_blank
    if self.class.columns_hash[self.class.primary_key.to_s]&.type == :string && self[self.class.primary_key].blank?
      self[self.class.primary_key] = SecureRandom.uuid
    end
  end
end
