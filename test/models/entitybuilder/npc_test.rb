# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class NpcTest < ActiveSupport::TestCase

    test "resident should have the necessary required validators" do
      npc = ResidentNpc.new(name: "CreatureTest")
      assert_not npc.valid?
      assert_equal [:core_rules, :resident_id], npc.errors.keys
    end

  end
end
