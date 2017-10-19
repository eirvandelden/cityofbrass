require 'test_helper'

module Entitybuilder
  class CharacterTest < ActiveSupport::TestCase

    test "resident should have the necessary required validators" do
      character = ResidentCharacter.new(name: "CharacterTest")
      assert_not character.valid?
      assert_equal [:core_rules, :resident_id], character.errors.keys
    end

  end
end
