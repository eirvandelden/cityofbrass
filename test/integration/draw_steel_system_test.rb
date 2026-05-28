require "test_helper"

class DrawSteelSystemTest < ActiveSupport::TestCase
  test "Draw Steel is registered in CoreRules.rulebooks" do
    names = CoreRules.rulebooks.map { |r| r["name"] }
    assert_includes names, "Draw Steel"
  end

  test "Draw Steel declares the six expected rule types" do
    types = CoreRules::Rule.rule_types("Draw Steel")
    assert_equal %w[Ancestry Class Kit Career Complication Condition].sort,
                 types.sort
  end

  test "Draw Steel has 57 core skills across 5 groups" do
    skills = CoreRules::Entity.core_skills("Draw Steel")
    assert_equal 57, skills.size
    groups = skills.map { |s| s["group"] }.uniq.sort
    assert_equal %w[Crafting Exploration Interpersonal Intrigue Lore], groups
  end
end
