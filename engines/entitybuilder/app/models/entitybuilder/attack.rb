module Entitybuilder
  class Attack < ApplicationRecord
    include Dice

    NULL_ATTRS = %w[ attack_dice damage_dice critical_damage_dice special_damage_dice ]
    POWER_USAGES = [ "At-will", "Encounter" ].freeze
    ACTION_TYPES = [ "Standard", "Minor", "Immediate interrupt", "Immediate reaction" ].freeze

    belongs_to :entity, inverse_of: :attacks

    validates :name, uniqueness: { scope: :entity_id }, presence: true, length: { maximum: 64 }
    validates :attack_type, presence: true

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

    validates :power_usage, inclusion: { in: POWER_USAGES }, allow_nil: true
    validates :action_type, inclusion: { in: ACTION_TYPES }
    validate :recharge_mark_allowed, if: :will_save_change_to_power_marks?
    validate :usable_at_will_mark_allowed, if: :will_save_change_to_power_marks?

    before_validation :nil_if_blank

    # Attack bonus and damage per [usage, multi_target, usable_at_will], from the monster's business card numbers.
    def power_prefill_options
      stats = entity.monster_stats if entity.respond_to?(:monster_stats)
      return {} unless stats

      combinations = POWER_USAGES.product([ false, true ], [ false, true ])
      combinations.index_with { |key| power_prefill(stats, *key) }
    end

    def recharges_when_bloodied_shown?
      recharges_when_bloodied? && entity.monster_group == "Elite"
    end

    def usable_at_will_shown?
      usable_at_will? && entity.monster_group == "Solo"
    end

    def has_details(ability_scores, modifiers)
      return true if attack_range.present?
      return true if damage_type.present?
      return true if critical_range.present?
      return true if critical_damage_dice.present?
      return true if calculated_critical_damage_bonus(ability_scores, modifiers).present?
      return true if special_damage_name.present?
      return true if special_damage_dice.present?
      return true if calculated_special_damage_bonus(ability_scores, modifiers).present?
      false
    end

    def game_dice(core_rules)
      return self.attack_dice if self.attack_dice?
      core_rules_dice(core_rules)
    end

    def display_dice?(dice)
      return false if CORE_DICE_MECHANICS.include? dice
      true
    end

    def calculated_attack_bonus(ability_scores, all_modifiers, all_base_values)
      if attack_bonus.present?
          bonus_placeholder = attack_bonus
      else
        bonus_placeholder = 0
        bonus_placeholder += self.attack_misc_modifier.to_i if self.attack_misc_modifier.present?

        ability_score = ability_scores.detect { |as| as.name == self.attack_ability_score } unless ability_scores.nil?
        bonus_placeholder += ability_score.modifier.to_i unless ability_score.nil?

        proficiency_bonus = all_base_values.detect { |d| d.name == "Proficiency Bonus" } if proficient?
        bonus_placeholder += proficiency_bonus.value.to_i unless proficiency_bonus.nil?

        base_attack_bonus = all_base_values.detect { |d| d.name == "Base Attack Bonus" }
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

      bonus_placeholder
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
      bonus_placeholder
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
      bonus_placeholder
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
      bonus_placeholder
    end

    private
      def recharge_mark_allowed
        return unless recharges_when_bloodied?

        errors.add(:recharges_when_bloodied, :not_elite) unless entity&.monster_group == "Elite"
        errors.add(:recharges_when_bloodied, :not_encounter) unless power_usage == "Encounter"
        errors.add(:recharges_when_bloodied, :already_marked) if other_marked_power?(:recharges_when_bloodied)
      end

      def other_marked_power?(mark)
        entity.attacks.where(mark => true).where.not(id: id).exists?
      end

      def usable_at_will_mark_allowed
        return unless usable_at_will?

        errors.add(:usable_at_will, :not_solo) unless entity&.monster_group == "Solo"
        errors.add(:usable_at_will, :not_encounter) unless power_usage == "Encounter"
        errors.add(:usable_at_will, :already_marked) if other_marked_power?(:usable_at_will)
      end

      def nil_if_blank
        NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
      end

      def power_prefill(stats, usage, multi_target, usable_at_will)
        at_will = usage == "At-will" || usable_at_will
        { attack_bonus: stats.attack_bonus,
          damage_bonus: stats.power_damage(usage: at_will ? :at_will : :encounter, multi_target: multi_target) }
      end

      def will_save_change_to_power_marks?
        will_save_change_to_recharges_when_bloodied? || will_save_change_to_usable_at_will? ||
          will_save_change_to_power_usage?
      end
  end
end
