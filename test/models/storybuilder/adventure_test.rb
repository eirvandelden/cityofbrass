require 'test_helper'

module Storybuilder
  class AdventureTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      adventure = ResidentAdventure.new(name: "AdventureTest")
      assert_not adventure.valid?
      assert_equal [:privacy, :resident_id], adventure.errors.keys
    end

  end
end
