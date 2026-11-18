require "test_helper"

module Entitybuilder
  class EncounterDifficultyTest < ActiveSupport::TestCase
    # Five characters of level 5 have a budget of 1000, so 200 experience is below it.
    def difficulty(experience, levels = [ 5 ] * 5)
      EncounterDifficulty.new(monster_experience: experience, party_levels: levels)
    end

    test "answers the campaign name it was given" do
      named = EncounterDifficulty.new(campaign_name: "Five Heroes", monster_experience: 200, party_levels: [ 5 ])

      assert_equal "Five Heroes", named.campaign_name
    end

    test "no rating for an empty party" do
      assert_nil difficulty(1000, []).rating
    end

    test "encounter level is 0 below the level 1 budget" do
      assert_equal 0, difficulty(499).encounter_level
    end

    test "encounter level is the highest level whose budget fits" do
      assert_equal 5, difficulty(1000).encounter_level
    end

    test "encounter level is capped at 40" do
      assert_equal 40, difficulty(100_000_000).encounter_level
    end

    test "party level rounds the average" do
      assert_equal 5, difficulty(1000, [ 5, 5, 4, 5 ]).party_level
      assert_equal 4, difficulty(1000, [ 4, 4, 5, 4 ]).party_level
    end

    test "party size counts the characters" do
      assert_equal 5, difficulty(1000).party_size
    end

    test "difference of -1 is easy" do
      assert_equal :easy, difficulty(800).rating
    end

    test "difference of 0 and 1 is standard" do
      assert_equal :standard, difficulty(1000).rating
      assert_equal :standard, difficulty(1250).rating
    end

    test "difference of 2 and 4 is hard" do
      assert_equal :hard, difficulty(1500).rating
      assert_equal :hard, difficulty(2000).rating
    end

    test "difference of 5 is impossible" do
      assert_equal :impossible, difficulty(2500).rating
    end
  end
end
