# frozen_string_literal: false

module Entitybuilder
  class InventoryItem < ApplicationRecord

    belongs_to :entity
    belongs_to :item, :class_name => "Rulebuilder::Item"

    has_many :modifiers, -> { order(:sort_order) }, :as => :modifierable, :dependent => :destroy
    accepts_nested_attributes_for :modifiers, :allow_destroy => true

    validates :item_id, presence: true, allow_nil: false
    validates :quantity, presence: true, numericality: { only_integer: true, greater_than: -1000000, less_than: 1000000 }
    validates :detail, length: { maximum: 40 }

    def name
      return item.name
    end

  end
end
