module Entitybuilder
  class CasterLevel < ApplicationRecord

    NULL_ATTRS = %w( dice )

    belongs_to :entity

    validates :caster_class, presence: true, length: { maximum: 64 }
    validates :level, uniqueness: { scope: [:entity_id, :caster_class] }, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :per_day, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :bonus_per_day, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :base_dc, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :ability_score, length: { maximum: 255 }
    validates :save_dc, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true

    def total_per_day
      return self.per_day.to_i + self.bonus_per_day.to_i
    end

    def calculated_dc(ability_scores, all_base_values)
      if self.save_dc.present?
          return self.save_dc
      else
        dc_placeholder = 0
        dc_placeholder += self.base_dc.to_i if self.base_dc?

        ability_score = ability_scores.detect { |as| as.name == self.ability_score } unless ability_scores.nil?
        dc_placeholder += ability_score.modifier.to_i unless ability_score.nil?

        proficiency_bonus = all_base_values.detect{ |d| d.name == "Proficiency Bonus" } if proficient?
        dc_placeholder += proficiency_bonus.value.to_i unless proficiency_bonus.nil?

        return dc_placeholder
      end
    end
  end
end
