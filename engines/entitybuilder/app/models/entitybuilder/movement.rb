module Entitybuilder
  class Movement < ApplicationRecord
    include Dice

    NULL_ATTRS = %w( dice )

    belongs_to :entity
    has_many :modifiers, -> { order(:sort_order) }, :as => :modifierable, :dependent => :destroy

    accepts_nested_attributes_for :modifiers, :allow_destroy => true

    validates :name, uniqueness: { scope: :entity_id }, presence: true, length: { maximum: 64 }
    validates :description, length: { maximum: 255 }
    validates :base, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :bonus, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :ability_score, length: { maximum: 255 }
    validates :misc_modifier, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :dice, length: { maximum: 255 }, format: { with: VALID_DICE_MECHANIC }, allow_nil: true

    before_validation :nil_if_blank

    def calculated_bonus(ability_scores, all_modifiers, all_base_values)
      if self.bonus.present?
        return self.bonus
      else
        bonus_placeholder = 0
        bonus_placeholder += self.base.to_i if self.base.present?
        bonus_placeholder += self.misc_modifier.to_i if self.misc_modifier.present?

        ability_score = ability_scores.detect { |as| as.name == self.ability_score } unless ability_scores.nil?
        bonus_placeholder += ability_score.modifier.to_i unless ability_score.nil?

        unless all_modifiers.nil?
          modifiers = all_modifiers.select { |m| m.category == "Movements" and m.item == self.name } unless all_modifiers.nil?
          modifiers.each do |m|
            bonus_placeholder += m.value if m.value.present?
          end
        end

        return bonus_placeholder
      end
    end

    private
      def nil_if_blank
        NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
      end
  end
end
