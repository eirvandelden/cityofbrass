require "test_helper"

class DrawSteelSystemTest < ActiveSupport::TestCase
  test "Draw Steel is registered in CoreRules.rulebooks" do
    names = CoreRules.rulebooks.map { |r| r["name"] }
    assert_includes names, "Draw Steel"
  end

  test "Draw Steel declares the six expected rule types" do
    types = CoreRules::Rule.rule_types("drawSteel")
    assert_equal %w[Ancestry Class Kit Career Complication Condition].sort,
                 types.sort
  end

  test "Draw Steel has 57 core skills across 5 groups" do
    skills = CoreRules::Entity.core_skills("drawSteel")
    assert_equal 57, skills.size
    groups = skills.map { |s| s["group"] }.uniq.sort
    assert_equal %w[Crafting Exploration Interpersonal Intrigue Lore], groups
  end

  test "Draw Steel separates inline attribution from FAQ lookup key" do
    license = CoreRules.license("drawSteel")

    assert license["core_faq"].blank?
    assert_match(/Draw Steel Creator License/, license["attribution"])
    assert_match(/MCDM Productions/, license["attribution"])
  end

  test "Draw Steel character has 5 ability scores: the characteristics" do
    abilities = CoreRules::Entity.defaults_values("drawSteel", "character", "ability_scores") || []
    assert_equal %w[Might Agility Reason Intuition Presence],
                 abilities.map { |a| a["name"] }
  end

  test "Draw Steel character has Stamina-related trackables" do
    trackables = CoreRules::Entity.defaults_values("drawSteel", "character", "trackables") || []
    names = trackables.map { |t| t["name"] }
    assert_includes names, "Stamina"
    assert_includes names, "Recoveries"
    assert_includes names, "Victories"
    assert_includes names, "Surges"
    assert_includes names, "Hero Tokens"
    assert_includes names, "Heroic Resource"
    assert_includes names, "Temporary Stamina"
  end

  test "Draw Steel character has identity descriptors" do
    descs = CoreRules::Entity.defaults_values("drawSteel", "character", "descriptors") || []
    names = descs.map { |d| d["name"] }
    %w[Ancestry Class Subclass Career Complication Languages].each do |n|
      assert_includes names, n, "expected descriptor: #{n}"
    end
    [ "Culture: Environment", "Culture: Organization", "Culture: Upbringing" ].each do |n|
      assert_includes names, n, "expected culture descriptor: #{n}"
    end
  end

  test "Draw Steel character has no defenses or saving_throws blocks (or empty)" do
    defenses = CoreRules::Entity.defaults_values("drawSteel", "character", "defenses") || []
    saves    = CoreRules::Entity.defaults_values("drawSteel", "character", "saving_throws") || []
    assert_equal 0, defenses.size
    assert_equal 0, saves.size
  end

  test "Draw Steel core_skills cover all 5 groups with expected counts" do
    skills = CoreRules::Entity.core_skills("drawSteel")
    by_group = skills.group_by { |s| s["group"] }
    assert_equal 10, by_group["Crafting"]&.size,      "Crafting count"
    assert_equal 10, by_group["Exploration"]&.size,   "Exploration count"
    assert_equal 13, by_group["Interpersonal"]&.size, "Interpersonal count"
    assert_equal 12, by_group["Intrigue"]&.size,      "Intrigue count"
    assert_equal 12, by_group["Lore"]&.size,          "Lore count"
  end

  test "Draw Steel creature has 5 characteristics too" do
    abilities = CoreRules::Entity.defaults_values("drawSteel", "creature", "ability_scores")
    assert_equal 5, abilities&.size
  end

  test "Draw Steel menu links to sheet sections that match has_many on Entity" do
    menu = CoreRules::Entity.menu("drawSteel")
    valid_links = %w[
      descriptors ability_scores base_values movements trackables
      class_levels caster_levels skills attacks defenses saving_throws
      currencies known_spells inventory_items linked_rules modifiers options
    ]
    assert_not_empty menu, "menu should not be empty after Phase 3"
    menu.each do |item|
      link_section = item["link"].split("?").first
      assert_includes valid_links, link_section,
        "menu link '#{item["link"]}' does not match a known sheet section"
    end
  end
end
