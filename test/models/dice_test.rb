require "test_helper"

class DiceTest < ActiveSupport::TestCase
  class Roller
    include Dice

    attr_accessor :dice
  end

  test "uses rulebook default dice for Draw Steel rolls" do
    roller = Roller.new

    dice = roller.game_dice("drawSteel")

    assert_equal "2d10", dice
    assert_equal "3", roller.display_dice_or_modifier("drawSteel", 3, dice)
  end

  test "VALID_DICE_MECHANIC matches a dice expression" do
    assert_match Dice::VALID_DICE_MECHANIC, "1d20+2d6"
  end

  test "VALID_DICE_MECHANIC matches Standard, Fate and Roll Under" do
    [ "Standard", "Fate", "Roll Under" ].each do |mechanic|
      assert_match Dice::VALID_DICE_MECHANIC, mechanic
    end
  end

  test "VALID_DICE_MECHANIC refuses a mechanic with text before or after it" do
    [ "foo Standard bar", "Standard ", "1d20 Fate", "xRoll Under" ].each do |value|
      assert_no_match Dice::VALID_DICE_MECHANIC, value
    end
  end

  test "VALID_DICE_MECHANIC refuses a trailing newline" do
    assert_no_match Dice::VALID_DICE_MECHANIC, "Fate\n"
  end
end
