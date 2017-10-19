module Entitybuilder
  class Skill < ApplicationRecord
    include ApplicationHelper
    include Dice

    NULL_ATTRS = %w( dice )

    belongs_to :entity
    has_many :modifiers, -> { order(:sort_order) }, :as => :modifierable, :dependent => :destroy

    accepts_nested_attributes_for :modifiers, :allow_destroy => true

    validates :name, uniqueness: { scope: :entity_id }, presence: true, length: { maximum: 64 }
    validates :description, length: { maximum: 6000 }
    validates :bonus, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :ability_score, length: { maximum: 255 }
    validates :ranks, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :misc_modifier, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :dice, length: { maximum: 255 }, format: { with: VALID_DICE_MECHANIC }, allow_nil: true

    before_validation :nil_if_blank

    def calculated_bonus(ability_scores, all_modifiers, all_base_values)
      if self.bonus.present?
          return self.bonus
      else
        bonus_placeholder = 0
        bonus_placeholder += self.ranks.to_i if self.ranks.present?
        bonus_placeholder += self.misc_modifier.to_i if self.misc_modifier.present?

        ability_score = ability_scores.detect { |as| as.name == self.ability_score } unless ability_scores.nil?
        bonus_placeholder += ability_score.modifier.to_i unless ability_score.nil?

        proficiency_bonus = all_base_values.detect{ |d| d.name == "Proficiency Bonus" } if proficient?
        bonus_placeholder += proficiency_bonus.value.to_i unless proficiency_bonus.nil?

        class_skill_bonus = all_base_values.detect{ |d| d.name == "Class Skill Bonus" } if class_skill? && ranks.to_i > 0
        bonus_placeholder += class_skill_bonus.value.to_i unless class_skill_bonus.nil?

        unless all_modifiers.nil?
          modifiers = all_modifiers.select { |m| m.category == "Skills" and m.item == self.name } unless all_modifiers.nil?
          modifiers.each do |m|
            bonus_placeholder += m.value if m.value.present?
          end
        end

        return bonus_placeholder
      end
    end

    def core_ability_score(core_rules)
      return CoreRules::Entity.core_skills(core_rules).select{ |v| v['name'] == name }.map { |m| m['ability_score'] }
    end

    private
      def nil_if_blank
        NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
      end

  end
end
