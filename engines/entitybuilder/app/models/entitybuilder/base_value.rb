# frozen_string_literal: false

module Entitybuilder
  class BaseValue < ApplicationRecord
    include Dice

    NULL_ATTRS = %w( dice )

    belongs_to :entity

    validates :name, uniqueness: { scope: :entity_id }, presence: true, length: { maximum: 64 }
    validates :description, length: { maximum: 6000 }
    validates :value, numericality: { only_integer: true, greater_than: -2147483648, less_than: 2147483647 }, allow_nil: true
    validates :dice, length: { maximum: 255 }, format: { with: VALID_DICE_MECHANIC }, allow_nil: true

    before_validation :nil_if_blank

    private
      def nil_if_blank
        NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
      end

  end
end
