module Dice
  extend ActiveSupport::Concern

  VALID_DICE = /\A([0-9]+)(d)([0-9]+)(\+*([0-9]+)(d)([0-9]+))*\z/
  VALID_DICE_MECHANIC = /\A([0-9]+)(d)([0-9]+)(\+*([0-9]+)(d)([0-9]+))*\z|\b(Standard)\b|\b(Fate)\b|\b(Roll Under)\b/

  CORE_RULES_DICE = [
    { core_rules: "3.5 Edition",       dice: "1d20" },
    { core_rules: "4th Edition",       dice: "1d20" },
    { core_rules: "5th Edition",       dice: "1d20" },
    { core_rules: "d20 Future",        dice: "1d20" },
    { core_rules: "d20 Modern",        dice: "1d20" },
    { core_rules: "Dungeon World",     dice: "2d6" },
    { core_rules: "Fate Core",         dice: "Fate" },
    { core_rules: "PFRPG",             dice: "1d20" },
    { core_rules: "W.O.I.N",           dice: "1d20" },
    { core_rules: "Generic",           dice: "1d20" },
    { core_rules: "Mutant Chronicles", dice: "2d20" }
  ]

  CORE_DICE_MECHANICS = [
    "Fate",
    "Roll Under",
    "Standard"
  ]

  def game_dice(core_rules)
    return self.dice if self.dice.present?
    core_rules_dice(core_rules)
  end

  def display_dice_or_modifier(core_rules, modifier, dice, display = nil)
    return "#{modifier}" if CORE_DICE_MECHANICS.include? dice

    return "#{modifier}" if core_rules_dice(core_rules).include? dice
    display.present? ? "#{display}" : "#{dice}"
  end

  private
    def core_rules_dice(core_rules)
      core_rules_dice_array = CORE_RULES_DICE.detect { |v| v[:core_rules] == core_rules }
      return core_rules_dice_array[:dice] if core_rules_dice_array.present?
      return CoreRules.default_dice(core_rules) if CoreRules.default_dice(core_rules).present?
      "1d20"
    end
end
