module Entitybuilder
  class Defense < ApplicationRecord

    belongs_to :defenseable

    validates :name, uniqueness: { scope: :entity_id }, presence: true, length: { maximum: 64 }
    validates :description, length: { maximum: 255 }
    validates :base, numericality: { only_integer: true, greater_than: -1000000, less_than: 1000000 }, allow_nil: true
    validates :bonus, numericality: { only_integer: true, greater_than: -1000000, less_than: 1000000 }, allow_nil: true
    validates :ability_score, length: { maximum: 255 }
    validates :misc_modifier, numericality: { only_integer: true, greater_than: -1000000, less_than: 1000000 }, allow_nil: true
    validates :dice, length: { maximum: 255 }

    def calculated_bonus(ability_scores, all_modifiers, all_base_values)
      if self.bonus.present?
          return self.bonus
      else
        bonus_placeholder = 0
        bonus_placeholder += self.base.to_i if self.base.present?
        bonus_placeholder += self.misc_modifier.to_i if self.misc_modifier.present?

        if self.name == 'CMD'
          bonus_placeholder += cmd_bonus(ability_scores, all_modifiers, all_base_values)
        else
          ability_score = ability_scores.detect { |as| as.name == self.ability_score } unless ability_scores.nil?
          bonus_placeholder += ability_score.modifier.to_i unless ability_score.nil?
        end

        unless all_modifiers.nil?
          modifiers = all_modifiers.select { |m| m.category == "Defenses" and m.item == self.name } unless all_modifiers.nil?
          modifiers.each do |m|
            bonus_placeholder += m.value if m.value.present?
          end
        end

        return bonus_placeholder
      end
    end

    def cmd_bonus(ability_scores, all_modifiers, all_base_values)
      bonus_placeholder = 0

      str = ability_scores.detect { |as| as.name == 'Strength' } unless ability_scores.nil?
      bonus_placeholder += str.modifier.to_i unless str.nil?

      dex = ability_scores.detect { |as| as.name == 'Dexterity' } unless ability_scores.nil?
      bonus_placeholder += dex.modifier.to_i unless dex.nil?

      base_attack_bonus = all_base_values.detect{ |d| d.name == "Base Attack Bonus" }
      bonus_placeholder += base_attack_bonus.value.to_i unless base_attack_bonus.nil?

      return bonus_placeholder
    end

  end
end
