require "test_helper"

class CoreRulesEntityMonsterBuilderTest < ActiveSupport::TestCase
  test "4th edition enables the monster builder" do
    assert CoreRules::Entity.monster_builder?("dnd4e")
  end

  test "pathfinder 2e does not" do
    assert_not CoreRules::Entity.monster_builder?("pf2e")
  end
end
