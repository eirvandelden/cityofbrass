require "test_helper"
require "rake"

class DrawSteelSeedTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("draw_steel:seed:ancestries")
  end

  test "ancestries seed task creates StockRules with attribution" do
    Rulebuilder::StockRule.where(core_rules: "Draw Steel", rule_type: "Ancestry").destroy_all

    Rake::Task["draw_steel:seed:ancestries"].reenable
    Rake::Task["draw_steel:seed:ancestries"].invoke

    rules = Rulebuilder::StockRule.where(core_rules: "Draw Steel", rule_type: "Ancestry")
    assert rules.count >= 9, "expected at least 9 ancestry records, got #{rules.count}"

    rules.each do |r|
      assert_equal "MCDM Productions", r.publisher
      assert_match(/Draw Steel:/, r.source.to_s)
      assert r.full_description.include?("Draw Steel Creator License"),
        "expected attribution in #{r.name}"
      assert r.is_shared, "expected is_shared=true on #{r.name}"
    end
  end

  test "seed task is idempotent — running twice does not duplicate" do
    Rulebuilder::StockRule.where(core_rules: "Draw Steel", rule_type: "Kit").destroy_all

    Rake::Task["draw_steel:seed:kits"].reenable
    Rake::Task["draw_steel:seed:kits"].invoke
    first_count = Rulebuilder::StockRule.where(core_rules: "Draw Steel", rule_type: "Kit").count

    Rake::Task["draw_steel:seed:kits"].reenable
    Rake::Task["draw_steel:seed:kits"].invoke
    second_count = Rulebuilder::StockRule.where(core_rules: "Draw Steel", rule_type: "Kit").count

    assert_equal first_count, second_count, "seed should be idempotent"
  end

  test "abilities seed task creates StockSpells with attribution" do
    Rulebuilder::StockSpell.where(core_rules: "Draw Steel").destroy_all

    Rake::Task["draw_steel:seed:abilities"].reenable
    Rake::Task["draw_steel:seed:abilities"].invoke

    spells = Rulebuilder::StockSpell.where(core_rules: "Draw Steel")
    assert spells.count >= 50, "expected many ability records, got #{spells.count}"

    sample = spells.first
    assert_equal "MCDM Productions", sample.publisher
    assert sample.full_description.include?("Draw Steel Creator License")
  end
end
