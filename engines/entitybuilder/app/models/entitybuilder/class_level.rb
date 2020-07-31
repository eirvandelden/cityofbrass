# frozen_string_literal: false

module Entitybuilder
  class ClassLevel < ApplicationRecord
    include Dice

    NULL_ATTRS = %w( hit_dice )

    belongs_to :entity
    has_many :modifiers, -> { order(:sort_order) }, :as => :modifierable, :dependent => :destroy

    accepts_nested_attributes_for :modifiers, :allow_destroy => true

    validates :name, presence: true, length: { maximum: 64 }
    validates :description, length: { maximum: 6000 }
    validates :level, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :hit_dice, length: { maximum: 255 }, format: { with: VALID_DICE }, allow_nil: true
    validates :hit_points, numericality: { only_integer: true, greater_than: -1000000, less_than: 1000000 }, allow_nil: true

    before_validation :nil_if_blank

    private
      def nil_if_blank
        NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
      end

  end
end
