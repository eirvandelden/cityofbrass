module Entitybuilder
  class Modifier < ApplicationRecord

    belongs_to :modifierable, polymorphic: true
    belongs_to :entity, inverse_of: :modifiers

    validates :modifierable_type, presence: true, allow_nil: false

    validates :category, presence: true, length: { maximum: 255 }
    validates :item, presence: true, length: { maximum: 255 }

    validates :value, presence: true, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }
    validates :dice, length: { maximum: 255 }

  end
end
