module Entitybuilder
  class Currency < ApplicationRecord

    belongs_to :entity

    validates :name, uniqueness: { scope: :entity_id }, presence: true, length: { maximum: 64 }
    validates :description, length: { maximum: 255 }
    validates :quantity, numericality: { only_integer: true, greater_than: -9223372036854775808, less_than: 9223372036854775807 }, allow_nil: true

  end
end
