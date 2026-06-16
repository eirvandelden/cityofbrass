require "test_helper"

class FifthEditionSystemTest < ActiveSupport::TestCase
  test "5th Edition is registered in CoreRules.rulebooks" do
    names = CoreRules.rulebooks.map { |r| r["name"] }
    assert_includes names, "5th Edition"
  end

  test "5th Edition declares the expected 2024 rule types" do
    types = CoreRules::Rule.rule_types("dnd5e")

    assert_equal %w[Ability Backgrounds Class Condition Feat Rule\ Reference Species Subclass].sort,
                 types.sort
  end

  test "5th Edition separates inline attribution from FAQ lookup key" do
    license = CoreRules.license("dnd5e")

    assert license["core_faq"].blank?
    assert_equal "Creative Commons Attribution 4.0 International", license["label"]
    assert_match(/System Reference Document 5\.2\.1/, license["attribution"])
    assert_match(/Wizards of the Coast LLC/, license["attribution"])
  end

  test "5th Edition character defaults use Species" do
    descriptors = CoreRules::Entity.defaults_values("dnd5e", "character", "descriptors") || []
    names = descriptors.map { |descriptor| descriptor["name"] }

    assert_includes names, "Species"
    assert_not_includes names, "Race"
  end
end
