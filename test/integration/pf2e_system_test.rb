require "test_helper"

class Pf2eSystemTest < ActiveSupport::TestCase
  test "Pathfinder 2e is registered in CoreRules.rulebooks" do
    names = CoreRules.rulebooks.map { |r| r["name"] }
    assert_includes names, "Pathfinder 2E"
  end

  test "Pathfinder 2e declares 10 expected rule types" do
    types = CoreRules::Rule.rule_types("pf2e")
    assert_equal 10, types.size
  end

  test "Pathfinder 2e has 17 core skills across 5 ability groups" do
    skills = CoreRules::Entity.core_skills("pf2e")
    assert_equal 17, skills.size
    groups = skills.map { |s| s["group"] }.uniq.sort
    assert_equal %w[Charisma Dexterity Intelligence Strength Wisdom], groups
  end

  test "Pathfinder 2e skills have correct per-group counts" do
    skills = CoreRules::Entity.core_skills("pf2e")
    by_group = skills.group_by { |s| s["group"] }
    assert_equal 1, by_group["Strength"]&.size,     "Strength count"
    assert_equal 3, by_group["Dexterity"]&.size,    "Dexterity count"
    assert_equal 5, by_group["Intelligence"]&.size, "Intelligence count"
    assert_equal 4, by_group["Wisdom"]&.size,       "Wisdom count"
    assert_equal 4, by_group["Charisma"]&.size,     "Charisma count"
  end

  test "Pathfinder 2e license has ORC label and core_faq key" do
    license = CoreRules.license("pf2e")
    assert_equal "ORC License", license["label"]
    assert_equal "License ORC", license["core_faq"]
    assert license["attribution"].present?
    assert_match(/ORC/, license["attribution"])
    assert_match(/Paizo/, license["attribution"])
  end

  test "Pathfinder 2e character has 6 ability scores" do
    ability_scores = CoreRules::Entity.defaults_values("pf2e", "character", "ability_scores") || []
    assert_equal %w[Strength Dexterity Constitution Intelligence Wisdom Charisma],
                 ability_scores.map { |a| a["name"] }
  end

  test "Pathfinder 2e character has HP, Hero Points, and Focus Points trackables" do
    trackables = CoreRules::Entity.defaults_values("pf2e", "character", "trackables") || []
    names = trackables.map { |t| t["name"] }
    assert_includes names, "Hit Points"
    assert_includes names, "Hero Points"
    assert_includes names, "Focus Points"
  end

  test "Pathfinder 2e character base_values includes Proficiency Bonus" do
    base_values = CoreRules::Entity.defaults_values("pf2e", "character", "base_values") || []
    names = base_values.map { |bv| bv["name"] }
    assert_includes names, "Proficiency Bonus"
    assert_includes names, "Level"
  end

  test "Pathfinder 2e character has Armor Class defense" do
    defenses = CoreRules::Entity.defaults_values("pf2e", "character", "defenses") || []
    assert_equal 1, defenses.size
    assert_equal "Armor Class", defenses.first["name"]
  end

  test "Pathfinder 2e character has Fortitude, Reflex, Will saving throws" do
    saves = CoreRules::Entity.defaults_values("pf2e", "character", "saving_throws") || []
    names = saves.map { |s| s["name"] }
    assert_includes names, "Fortitude"
    assert_includes names, "Reflex"
    assert_includes names, "Will"
    assert_equal 3, saves.size
  end

  test "Pathfinder 2e creature has 6 ability scores" do
    abilities = CoreRules::Entity.defaults_values("pf2e", "creature", "ability_scores")
    assert_equal 6, abilities&.size
  end

  test "Pathfinder 2e creature has Hit Points only (no Hero/Focus)" do
    trackables = CoreRules::Entity.defaults_values("pf2e", "creature", "trackables") || []
    names = trackables.map { |t| t["name"] }
    assert_includes names, "Hit Points"
    assert_not_includes names, "Hero Points"
    assert_not_includes names, "Focus Points"
  end

  test "Pathfinder 2e character has identity descriptors" do
    descs = CoreRules::Entity.defaults_values("pf2e", "character", "descriptors") || []
    names = descs.map { |d| d["name"] }
    %w[Ancestry Heritage Background Class Deity Alignment Languages].each do |n|
      assert_includes names, n, "expected descriptor: #{n}"
    end
  end

  test "Pathfinder 2e menu links to valid sheet sections" do
    menu = CoreRules::Entity.menu("pf2e")
    valid_links = %w[
      descriptors ability_scores base_values movements trackables
      class_levels caster_levels skills attacks defenses saving_throws
      currencies known_spells inventory_items linked_rules modifiers options
    ]
    assert_not_empty menu
    menu.each do |item|
      link_section = item["link"].split("?").first
      assert_includes valid_links, link_section,
        "menu link '#{item["link"]}' does not match a known sheet section"
    end
  end

  test "Pathfinder 2e is a d20 system with 1d20 default dice" do
    rulebook = CoreRules.rulebooks.find { |r| r["name"] == "Pathfinder 2E" }
    assert_equal "true", rulebook["d20_system"]
    assert_equal "1d20", rulebook["default_dice"]
  end
end
