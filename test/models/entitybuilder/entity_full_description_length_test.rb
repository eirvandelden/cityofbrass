require 'test_helper'

module Entitybuilder
  class EntityFullDescriptionLengthTest < ActiveSupport::TestCase
    test "entity with 50,000-character full_description is valid" do
      entity = entitybuilder_entities(:resident_character_one)
      entity.full_description = "x" * 50_000
      assert entity.valid?
    end

    test "entity with 60,001-character full_description is invalid" do
      entity = entitybuilder_entities(:resident_character_one)
      entity.full_description = "x" * 60_001
      assert entity.invalid?
    end
  end
end
