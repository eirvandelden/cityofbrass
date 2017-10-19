module Entitybuilder
  module ApplicationHelper

    def get_type_label(record, type)
      type_label = record.present? ? type_split(@linked_rule.rule.type.demodulize)[0] : type.humanize
      return type_label
    end

    def core_dice_mechanics
      return [
        'Fate',
        'Roll Under',
        'Standard'
      ]
    end

    def eb_base_value_options
      return [
        'Base Attack Bonus',
        'Class Skill Bonus',
        'Proficiency Bonus'
      ]
    end

    def eb_attack_type_options
      return [
        'Melee',
        'Range',
        'Special'
      ]
    end

    def eb_modifier_category_options
      return [
        'Ability Scores',
        'Movements',
        'Skills',
        'Attacks',
        'All Attacks',
        'Defenses',
        'Saving Throws'
      ]
    end

    def eb_modifier_attack_options
      return [
        'Attack',
        'Melee Attack',
        'Range Attack',
        'Damage'
      ]
    end

  end
end
