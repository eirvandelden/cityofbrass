module Entitybuilder
  module AttackPowerHelper
    def monster_powers?(entity)
      entity.monster_built?
    end

    def power_usage_options
      [ [ t("entitybuilder.attacks.power_fields.usage_at_will"), "At-will" ],
        [ t("entitybuilder.attacks.power_fields.usage_encounter"), "Encounter" ] ]
    end

    def action_type_options
      [ [ t("entitybuilder.attacks.power_fields.action_standard"), "Standard" ],
        [ t("entitybuilder.attacks.power_fields.action_minor"), "Minor" ],
        [ t("entitybuilder.attacks.power_fields.action_immediate_interrupt"), "Immediate interrupt" ],
        [ t("entitybuilder.attacks.power_fields.action_immediate_reaction"), "Immediate reaction" ] ]
    end

    def power_usage_label(attack)
      power_usage_options.to_h { |label, value| [ value, label ] }[attack.power_usage]
    end

    def action_type_label(attack)
      action_type_options.to_h { |label, value| [ value, label ] }[attack.action_type]
    end

    def power_prefill_json(attack)
      attack.power_prefill_options.map do |(usage, multi_target, usable_at_will), numbers|
        { usage: usage, multi_target: multi_target, usable_at_will: usable_at_will }.merge(numbers)
      end.to_json
    end
  end
end
