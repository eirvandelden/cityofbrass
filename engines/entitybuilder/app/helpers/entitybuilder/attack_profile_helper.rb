module Entitybuilder
  module AttackProfileHelper

    def attack_display_profile(core_rules, attack, ability_scores, all_modifiers, all_base_values)
      begin
        # get all of the calculated bonuses
        calc_attack_bonus = attack.calculated_attack_bonus(ability_scores, all_modifiers, all_base_values)
        calc_damage_bonus = attack.calculated_damage_bonus(ability_scores, all_modifiers)
        calc_critical_bonus = attack.calculated_critical_damage_bonus(ability_scores, all_modifiers)
        calc_special_bonus = attack.calculated_special_damage_bonus(ability_scores, all_modifiers)

        # build attack vars
        attack_name  = "<span class='color-secondary'>#{sanitize(attack.name)}</span> "
        attack_dice  = "#{attack.attack_dice}" if attack.display_dice?(attack.attack_dice)
        attack_bonus = "#{calc_attack_bonus}" unless (calc_attack_bonus == "+0" and attack.attack_bonus.to_s.blank?)

        # build damage vars
        damage_dice  = attack.damage_dice.present? ? "#{attack.damage_dice}" : ""
        damage_bonus =  calc_damage_bonus.present? ? "#{calc_damage_bonus}" : ""
        normal_damage = "#{damage_dice}#{damage_bonus}"
        damage = []
        damage << "#{damage_dice}#{damage_bonus}" if normal_damage.present?
        damage << "#{sanitize(attack.critical_range)}" if attack.critical_range.present?
        damage << "#{sanitize(attack.damage_type)}" if attack.damage_type.present?

        # build critical vars
        critical_dice = "#{attack.critical_damage_dice}"
        critical_bonus= "#{calc_critical_bonus}"

        # build special vars
        special_name = attack.special_damage_name.blank? ? 'Special' : sanitize(attack.special_damage_name)
        special_dice = "#{attack.special_damage_dice}"
        special_bonus= "#{calc_special_bonus}"

        full_attack = ""
        full_attack << "#{format_attack_profile(attack_name, attack_dice, attack_bonus)}"
        full_attack << "#{format_damage_profile(damage)}"
        full_attack << "#{format_critical_profile(critical_dice, critical_bonus)}"
        full_attack << "#{format_special_profile(special_name, special_dice, special_bonus)}"
        full_attack << "#{format_range(attack.attack_type, sanitize(attack.attack_range))}"

        return full_attack
      rescue => e
        logger.error "Error: #{e.message}"
        return "Unable to display (#{attack.name})"
      end
    end

    def format_attack_profile(name, dice, bonus)
      return "<strong>#{name}</strong> #{dice}#{bonus}"
    end

    def format_damage_profile(damage)
      return (damage.size > 0) ? " <span class='nowrap'>( #{damage.join(" / ")} )</span>" : ""
    end

    def format_critical_profile(dice, bonus)
      return (dice.present? || bonus.present?) ? " <span class='nowrap'>[ <span class='color-c5'>Critical</span> #{dice}#{bonus} ]</span>" : ""
    end

    def format_special_profile(name, dice, bonus)
      return ((name.present? and name != "Special") || dice.present? || bonus.present?) ?  " <span class='nowrap'>[ <span class='color-c5'>#{name}</span> #{dice}#{bonus} ]</span>" : ""
    end

  end
end
