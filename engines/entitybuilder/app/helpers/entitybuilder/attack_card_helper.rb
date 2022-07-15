module Entitybuilder
  module AttackCardHelper

    def attack_display_card(core_rules, attack, ability_scores, all_modifiers, all_base_values)
      begin
        # get all of the calculated bonuses
        calc_attack_bonus = attack.calculated_attack_bonus(ability_scores, all_modifiers, all_base_values)
        calc_damage_bonus = attack.calculated_damage_bonus(ability_scores, all_modifiers)
        calc_critical_bonus = attack.calculated_critical_damage_bonus(ability_scores, all_modifiers)
        calc_special_bonus = attack.calculated_special_damage_bonus(ability_scores, all_modifiers)

        # build attack vars
        'color-secondary'>#{sanitize(attack.name)}</span> "
        attack_dice  = "#{attack.game_dice(core_rules)}"
        attack_bonus = "#{calc_attack_bonus}" unless (calc_attack_bonus == "+0" and attack.attack_bonus.to_s.blank?)
        attack_display = attack.display_dice_or_modifier(core_rules, attack_bonus, attack_dice, "#{attack_dice}#{attack_bonus.to_s}")
        attack_display = attack_display.blank? ? "+0" : attack_display

        # build damage vars
        damage_dice  = attack.damage_dice.present? ? "#{attack.damage_dice}" : ""
        damage_bonus =  calc_damage_bonus.present? ? "#{calc_damage_bonus}" : ""
        normal_damage = "#{damage_dice}#{damage_bonus}"
        damage = []
        damage << "#{format_damage_roller("#{sanitize(attack.name)} [dmg]", damage_dice, damage_bonus)}" if normal_damage.present?
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
        full_attack << "#{format_attack_card(sanitize(attack.name), attack_dice, attack_bonus, attack_display)}"
        full_attack << "#{format_damage_card(damage)}"
        full_attack << "#{format_critical_card(sanitize(attack.name), critical_dice, critical_bonus)}"
        full_attack << "#{format_special_card(sanitize(attack.name), special_dice, special_bonus, special_name)}"
        full_attack << "#{format_range(attack.attack_type, sanitize(attack.attack_range))}"

        return full_attack
      rescue => e
        logger.error "Error: #{e.message}"
        return "Unable to display (#{sanitize(attack.name)})"
      end
    end

    def format_attack_card(name, dice, bonus, display)
      return "<strong>#{name}</strong> #{format_attack_roller(name, dice, bonus, display)}"
    end

    def format_damage_card(damage)
      return (damage.size > 0) ? " (#{damage.join(" / ")})" : ""
    end

    def format_critical_card(name, dice, bonus)
      if dice.present?
        critical = (dice.present? || bonus.present?) ? " [<span class='color-c5'>Critical</span> #{format_damage_roller("#{name} [crit-dmg]", dice, bonus)}]" : ""
      else
        critical = (bonus.present?) ? " [<span class='color-c5'>Critical</span> #{bonus}]" : ""
      end

      return critical
    end

    def format_special_card(name, dice, bonus, special_name)
      if dice.present?
        special = ((special_name.present? and special_name != "Special") || dice.present? || bonus.present?) ?  " [<span class='color-c5'>#{special_name}</span> #{format_damage_roller("#{name} #{special_name}", dice, bonus)}]" : ""
      else
        special = ((special_name.present? and special_name != "Special") || dice.present? || bonus.present?) ?  " [<span class='color-c5'>#{special_name}</span> #{bonus}]" : ""
      end

      return special
    end

    def format_attack_roller(name, dice, bonus, display)
      bonus = bonus.present? ? "#{bonus}" : "+0"
      roll = "#{dice}#{bonus}"

      if @show_popbox.present?
        return format_dice_popup(display, dice, bonus)
      else
        return format_dice_activeplay(display, name, roll)
      end
    end

    def format_damage_roller(name, dice, bonus)
      bonus = bonus.present? ? "#{bonus}" : "+0"
      roll = "#{dice}#{bonus}"
      display = (bonus=="+0")? "#{dice}" : "#{dice}#{bonus}"

      if @show_popbox.present?
        return format_dice_popup(display, dice, bonus)
      else
        return format_dice_activeplay(display, name, roll)
      end
    end

  end
end
