require 'test_helper'

module Entitybuilder
  class CreatureTest < ActiveSupport::TestCase

    test "resident should have the necessary required validators" do
      creature = ResidentCharacter.new(name: "CreatureTest")
      assert_not creature.valid?
      assert_equal [:core_rules, :resident_id], creature.errors.keys
    end

  end
end
