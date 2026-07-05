require 'test_helper'

module Storybuilder
  class AdventureTest < ActiveSupport::TestCase

    test "should have the necessary required validators" do
      adventure = ResidentAdventure.new(name: "AdventureTest")
      assert_not adventure.valid?
      assert_equal [:privacy, :resident, :resident_id], adventure.errors.attribute_names
    end

    test "can_show? returns true for Public privacy with nil user" do
      adventure = storybuilder_adventures(:resident_one)
      adventure.privacy = 'Public'
      assert adventure.can_show?(nil, false)
    end

    test "can_show? returns false for Private privacy with nil user" do
      adventure = storybuilder_adventures(:resident_one)
      adventure.privacy = 'Private'
      assert_not adventure.can_show?(nil, false)
    end

  end
end
