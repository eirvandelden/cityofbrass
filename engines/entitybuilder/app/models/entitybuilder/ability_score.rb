# frozen_string_literal: false

module Entitybuilder
  class AbilityScore < ApplicationRecord
    include Dice

    NULL_ATTRS = %w( dice )

    belongs_to :entity
    has_many :modifiers, -> { order(:sort_order) }, :as => :modifierable, :dependent => :destroy

    accepts_nested_attributes_for :modifiers, :allow_destroy => true

    validates :name, uniqueness: { scope: :entity_id }, presence: true, length: { maximum: 64 }
    validates :description, length: { maximum: 6000 }
    validates :base, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :score, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :modifier, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :dice, length: { maximum: 255 }, format: { with: VALID_DICE_MECHANIC }, allow_nil: true

    before_validation :nil_if_blank

    def calculated_score(all_modifiers)
      if self.score.present?
          return self.score
      else
        score_placeholder = self.base.to_i

        unless all_modifiers.nil?
          modifiers = all_modifiers.select { |m| m.category == "Ability Scores" and m.item == self.name } unless all_modifiers.nil?
          modifiers.each do |m|
            score_placeholder += m.value if m.value.present?
          end
        end

        return score_placeholder
      end
    end

    def calculated_modifier(all_modifiers)
      if self.modifier.present?
          return self.modifier
      else
        modifier_placeholder = 0

        #unless all_modifiers.nil?
        #  modifiers = all_modifiers.select { |m| m.category == "Ability Scores" and m.item == self.name } unless all_modifiers.nil?
        #  modifiers.each do |m|
        #    modifier_placeholder += m.value if m.value.present?
        #  end
        #end

        return modifier_placeholder
      end
    end

    private
      def nil_if_blank
        NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
      end

  end
end
