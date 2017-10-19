require 'test_helper'

module Entitybuilder
  class AbilityScoreTest < ActiveSupport::TestCase

    test "ability_score should have the necessary required validators" do
      ability_score = AbilityScore.new(name: "AbilityScoreTest")
      assert ability_score.valid?
    end

  end
end
