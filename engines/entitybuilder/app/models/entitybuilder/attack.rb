# frozen_string_literal: false

module Entitybuilder
  class Attack < ApplicationRecord
    include Dice

    NULL_ATTRS = %w( attack_dice damage_dice critical_damage_dice special_damage_dice )

    belongs_to :entity

    validates :name, uniqueness: { scope: :entity_id }, presence: true, length: { maximum: 64 }
    validates :attack_type, presence: true
    validates :description, length: { maximum: 6000 }

    validates :attack_range, length: { maximum: 20 }
    validates :attack_ability_score, length: { maximum: 255 }
    validates :attack_dice, length: { maximum: 255 }, format: { with: VALID_DICE_MECHANIC }, allow_nil: true
    validates :attack_bonus, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :attack_misc_modifier, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true

    validates :damage_ability_score, length: { maximum: 255 }
    validates :damage_dice, length: { maximum: 255 }, format: { with: VALID_DICE }, allow_nil: true
    validates :damage_bonus, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :damage_misc_modifier, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true

    validates :critical_damage_ability_score, length: { maximum: 255 }
    validates :critical_damage_dice, length: { maximum: 255 }, format: { with: VALID_DICE }, allow_nil: true
    validates :critical_damage_bonus, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :critical_damage_misc_modifier, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true

    validates :special_damage_name, length: { maximum: 40 }
    validates :special_damage_ability_score, length: { maximum: 255 }
    validates :special_damage_dice, length: { maximum: 255 }, format: { with: VALID_DICE }, allow_nil: true
    validates :special_damage_bonus, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :special_damage_misc_modifier, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true

    validates :critical_range, length: { maximum: 64 }

    before_validation :nil_if_blank

    def has_details(ability_scores, modifiers)
      return true if attack_range.present?
      return true if damage_type.present?
      return true if critical_range.present?
      return true if critical_damage_dice.present?
      return true if calculated_critical_damage_bonus(ability_scores, modifiers).present?
      return true if special_damage_name.present?
      return true if special_damage_dice.present?
      return true if calculated_special_damage_bonus(ability_scores, modifiers).present?
      return false
    end

    def game_dice(core_rules)
      core_rules_dice_array = CORE_RULES_DICE.detect{ |v| v[:core_rules] == core_rules }
      core_rules_dice = core_rules_dice_array[:dice] unless core_rules_dice_array.nil?

      return self.attack_dice if self.attack_dice?
      return core_rules_dice unless core_rules_dice.nil?
      return '1d20'
    end

    def display_dice?(dice)
      return false if CORE_DICE_MECHANICS.include?dice
      return true
    end

    def calculated_attack_bonus(ability_scores, all_modifiers, all_base_values)
      if attack_bonus.present?
          bonus_placeholder = attack_bonus
      else
        bonus_placeholder = 0
        bonus_placeholder += self.attack_misc_modifier.to_i if self.attack_misc_modifier.present?

        ability_score = ability_scores.detect { |as| as.name == self.attack_ability_score } unless ability_scores.nil?
        bonus_placeholder += ability_score.modifier.to_i unless ability_score.nil?

        proficiency_bonus = all_base_values.detect{ |d| d.name == "Proficiency Bonus" } if proficient?
        bonus_placeholder += proficiency_bonus.value.to_i unless proficiency_bonus.nil?

        base_attack_bonus = all_base_values.detect{ |d| d.name == "Base Attack Bonus" }
        bonus_placeholder += base_attack_bonus.value.to_i unless base_attack_bonus.nil?

        unless all_modifiers.nil?
          modifiers = all_modifiers.select { |m| m.category == "Attacks" and m.item == self.name }
          modifiers.each do |m|
            bonus_placeholder += m.value if m.value.present?
          end
        end

        unless all_modifiers.nil?
          modifiers = all_modifiers.select { |m| m.category == "All Attacks" and m.item == "Attack" }
          modifiers += all_modifiers.select { |m| m.category == "All Attacks" and m.item == "#{self.attack_type} Attack" }
          modifiers.each do |m|
            bonus_placeholder += m.value if m.value.present?
          end
        end
      end

      bonus_placeholder = "+#{bonus_placeholder}" if bonus_placeholder > -1

      return bonus_placeholder

    end

    def calculated_damage_bonus(ability_scores, all_modifiers)
      if damage_bonus.present?
          bonus_placeholder = damage_bonus
      else
        bonus_placeholder = 0
        bonus_placeholder += self.damage_misc_modifier.to_i if self.damage_misc_modifier?

        ability_score = ability_scores.detect { |as| as.name == self.damage_ability_score } unless ability_scores.nil?
        bonus_placeholder += ability_score.modifier.to_i unless ability_score.nil?

        unless all_modifiers.nil?
          modifiers = all_modifiers.select { |m| m.category == "Attacks" and m.item == self.name }
          modifiers.each do |m|
            bonus_placeholder += m.value if m.value.present?
          end
        end

        unless all_modifiers.nil?
          modifiers = all_modifiers.select { |m| m.category == "All Attacks" and m.item == "Damage" }
          modifiers.each do |m|
            bonus_placeholder += m.value if m.value.present?
          end
        end
      end

      bonus_placeholder = "+#{bonus_placeholder}" if bonus_placeholder > -1

      return '' if bonus_placeholder == '+0'
      return bonus_placeholder
    end

    def calculated_critical_damage_bonus(ability_scores, all_modifiers)
      if critical_damage_bonus.present?
          bonus_placeholder = critical_damage_bonus
      else
        bonus_placeholder = 0
        bonus_placeholder += self.critical_damage_misc_modifier.to_i if self.critical_damage_misc_modifier?

        ability_score = ability_scores.detect { |as| as.name == self.critical_damage_ability_score } unless ability_scores.nil?
        bonus_placeholder += ability_score.modifier.to_i unless ability_score.nil?

        unless all_modifiers.nil?
          modifiers = all_modifiers.select { |m| m.category == "All Attacks" and m.item == "Critical Damage" }
          modifiers.each do |m|
            bonus_placeholder += m.value if m.value.present?
          end
        end
      end

      bonus_placeholder = "+#{bonus_placeholder}" if bonus_placeholder > -1

      return '' if bonus_placeholder == '+0'
      return bonus_placeholder
    end

    def calculated_special_damage_bonus(ability_scores, all_modifiers)
      if special_damage_bonus.present?
          bonus_placeholder = special_damage_bonus
      else
        bonus_placeholder = 0
        bonus_placeholder += self.special_damage_misc_modifier.to_i if self.special_damage_misc_modifier?

        ability_score = ability_scores.detect { |as| as.name == self.special_damage_ability_score } unless ability_scores.nil?
        bonus_placeholder += ability_score.modifier.to_i unless ability_score.nil?

        unless all_modifiers.nil?
          modifiers = all_modifiers.select { |m| m.category == "All Attacks" and m.item == "Special Damage" }
          modifiers.each do |m|
            bonus_placeholder += m.value if m.value.present?
          end
        end
      end

      bonus_placeholder = "+#{bonus_placeholder}" if bonus_placeholder > -1

      return '' if bonus_placeholder == '+0'
      return bonus_placeholder
    end

    private
      def nil_if_blank
        NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
      end

  end
end
