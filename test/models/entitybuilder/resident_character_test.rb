require "test_helper"

module Entitybuilder
  class ResidentCharacterTest < ActiveSupport::TestCase
    test "character level sums class levels" do
      assert_equal 3, entitybuilder_entities(:dnd4e_hero_level_3_0).character_level
    end

    test "character level is 1 without class levels" do
      assert_equal 1, entitybuilder_entities(:resident_character_one).character_level
    end
  end
end
