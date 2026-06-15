module Dice
  extend ActiveSupport::Concern

  VALID_DICE = /\A([0-9]+)(d)([0-9]+)(\+*([0-9]+)(d)([0-9]+))*\z/
  VALID_DICE_MECHANIC = /\A([0-9]+)(d)([0-9]+)(\+*([0-9]+)(d)([0-9]+))*\z|\b(Standard)\b|\b(Fate)\b|\b(Roll Under)\b/

  CORE_RULES_DICE = [
    { core_rules: "dnd35e",           dice: "1d20" },
    { core_rules: "dnd4e",            dice: "1d20" },
    { core_rules: "dnd5e",            dice: "1d20" },
    { core_rules: "d20Future",        dice: "1d20" },
    { core_rules: "d20Modern",        dice: "1d20" },
    { core_rules: "Dungeon World",    dice: "2d6" },
    { core_rules: "fateCore",         dice: "Fate" },
    { core_rules: "pf1e",             dice: "1d20" },
    { core_rules: "woin",             dice: "1d20" },
    { core_rules: "generic",          dice: "1d20" },
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
