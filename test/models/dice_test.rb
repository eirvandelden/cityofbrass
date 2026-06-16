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
end
