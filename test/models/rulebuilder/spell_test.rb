require 'test_helper'

module Rulebuilder
  class SpellTest < ActiveSupport::TestCase
    test "resident should have the necessary required validators" do
      spell = ResidentSpell.new(name: "ResidentSpellTest")
      assert_not spell.valid?
      assert_equal [:core_rules, :resident_id], spell.errors.keys
    end

    test "proprietary should have the necessary required validators" do
      spell = ProprietarySpell.new(name: "ProprietarySpellTest")
      assert_not spell.valid?
      assert_equal [:core_rules], spell.errors.keys
    end

    test "list helpers return comma separated values" do
      spell = rulebuilder_spells(:resident_one)

      assert_equal "hello1, world2", spell.tag_list
      assert_equal "One, Two", spell.level_list
    end
  end
end
