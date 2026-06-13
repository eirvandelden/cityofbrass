require 'test_helper'

module Entitybuilder
  class EntityTest < ActiveSupport::TestCase
    test "tag_list returns a comma separated list" do
      assert_equal "hello1, world2", entitybuilder_entities(:resident_character_one).tag_list
    end

    test "can_show? returns true for Public privacy with nil user" do
      entity = entitybuilder_entities(:resident_creature_one)
      entity.privacy = 'Public'
      assert entity.can_show?(nil, false, entity.type)
    end

    test "can_show? returns false for Residents privacy with nil user" do
      entity = entitybuilder_entities(:resident_creature_one)
      entity.privacy = 'Residents'
      assert_not entity.can_show?(nil, false, entity.type)
    end

    test "can_sheet? returns true for Public sheet_privacy with nil user" do
      entity = entitybuilder_entities(:resident_creature_one)
      entity.sheet_privacy = 'Public'
      assert entity.can_sheet?(nil, false, entity.type)
    end

    test "can_sheet? returns false for Private sheet_privacy with nil user" do
      entity = entitybuilder_entities(:resident_creature_one)
      entity.sheet_privacy = 'Private'
      assert_not entity.can_sheet?(nil, false, entity.type)
    end
  end
end
