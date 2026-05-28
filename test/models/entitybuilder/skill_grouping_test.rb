require "test_helper"

module Entitybuilder
  class SkillGroupingTest < ActiveSupport::TestCase
    test "skill records accept a skill_group string" do
      entity = entitybuilder_entities(:resident_character_one)
      skill = entity.skills.create!(
        name: "Test Skill",
        skill_group: "Lore",
        ability_score: "Intelligence",
        sort_order: 999
      )

      assert_equal "Lore", skill.reload.skill_group
    end

    test "skill_group is optional (nil allowed for ungrouped systems)" do
      entity = entitybuilder_entities(:resident_character_one)
      skill = entity.skills.create!(
        name: "Test Skill Ungrouped",
        ability_score: "Wisdom",
        sort_order: 998
      )

      assert_nil skill.reload.skill_group
    end

    test "skill_group rejects values over 64 chars" do
      entity = entitybuilder_entities(:resident_character_one)
      skill = entity.skills.build(
        name: "Test",
        ability_score: "Strength",
        sort_order: 997,
        skill_group: "x" * 65
      )

      assert_not skill.valid?
      assert skill.errors[:skill_group].any?
    end

    test "CoreRules::Entity.add_core_skills propagates group from JSON" do
      original = CoreRules.rulebooks
      CoreRules.rulebooks = original + [ {
        "name" => "TestGroupingSystem",
        "active" => "true",
        "entitybuilder" => {
          "core_skills" => [
            { "name" => "Test Crafting Skill",  "ranks" => "0", "ability_score" => "Intelligence", "group" => "Crafting" },
            { "name" => "Test Ungrouped Skill", "ranks" => "0", "ability_score" => "Wisdom" }
          ],
          "character"   => {},
          "creature"    => {}
        },
        "rulebuilder" => { "rules" => [], "powers" => [] }
      } ]

      entity = entitybuilder_entities(:resident_character_one)
      entity.skills.destroy_all
      entity.update!(core_rules: "TestGroupingSystem")
      CoreRules::Entity.add_core_skills(entity)

      grouped   = entity.skills.find_by(name: "Test Crafting Skill")
      ungrouped = entity.skills.find_by(name: "Test Ungrouped Skill")

      assert_equal "Crafting", grouped.skill_group
      assert_nil ungrouped.skill_group
    ensure
      CoreRules.rulebooks = original
    end
  end
end
