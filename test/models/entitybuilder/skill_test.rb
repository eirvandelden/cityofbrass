require "test_helper"

module Entitybuilder
  class SkillTest < ActiveSupport::TestCase
    setup do
      @entity = entitybuilder_entities(:resident_character_one)
    end

    test "a dice expression is valid" do
      assert_predicate build_skill("1d20+2d6"), :valid?
    end

    test "each named dice mechanic is valid" do
      [ "Fate", "Standard", "Roll Under" ].each do |mechanic|
        assert_predicate build_skill(mechanic), :valid?, "#{mechanic} should be valid"
      end
    end

    test "a dice mechanic with text around it is invalid" do
      skill = build_skill("foo Standard bar")

      assert_not skill.valid?
      assert_includes skill.errors.attribute_names, :dice
    end

    test "a skill without dice is valid" do
      assert_predicate build_skill(nil), :valid?
    end

    test "a skill with a legacy dice value saves when another field changes" do
      skill = build_skill("1d20")
      skill.save!
      skill.update_column(:dice, "1d20 Standard")

      skill.name = "Renamed"

      assert skill.save
    end

    private
      def build_skill(dice)
        Skill.new(entity: @entity, name: "Dice test", dice: dice)
      end
  end
end
