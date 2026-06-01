require "test_helper"
require "rake"

class DrawSteelSeedTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("db:seed:draw_steel:ancestries")
  end

  test "ancestries seed task creates StockRules with attribution" do
    Rulebuilder::StockRule.where(core_rules: "Draw Steel", rule_type: "Ancestry").destroy_all

    Rake::Task["db:seed:draw_steel:ancestries"].reenable
    Rake::Task["db:seed:draw_steel:ancestries"].invoke

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

    Rake::Task["db:seed:draw_steel:kits"].reenable
    Rake::Task["db:seed:draw_steel:kits"].invoke
    first_count = Rulebuilder::StockRule.where(core_rules: "Draw Steel", rule_type: "Kit").count

    Rake::Task["db:seed:draw_steel:kits"].reenable
    Rake::Task["db:seed:draw_steel:kits"].invoke
    second_count = Rulebuilder::StockRule.where(core_rules: "Draw Steel", rule_type: "Kit").count

    assert_equal first_count, second_count, "seed should be idempotent"
  end

  test "classes seed task creates valid StockRules with long descriptions" do
    Rulebuilder::StockRule.where(core_rules: "Draw Steel", rule_type: "Class").destroy_all

    Rake::Task["db:seed:draw_steel:classes"].reenable
    Rake::Task["db:seed:draw_steel:classes"].invoke

    rules = Rulebuilder::StockRule.where(core_rules: "Draw Steel", rule_type: "Class")
    assert_equal 9, rules.count
    assert rules.all?(&:valid?), "expected seeded class records to be valid"
  end

  test "abilities seed task creates StockSpells with attribution" do
    Rulebuilder::StockSpell.where(core_rules: "Draw Steel").destroy_all

    Rake::Task["db:seed:draw_steel:abilities"].reenable
    Rake::Task["db:seed:draw_steel:abilities"].invoke

    spells = Rulebuilder::StockSpell.where(core_rules: "Draw Steel")
    assert spells.count >= 50, "expected many ability records, got #{spells.count}"

    sample = spells.first
    assert_equal "MCDM Productions", sample.publisher
    assert sample.full_description.include?("Draw Steel Creator License")
  end

  test "abilities seed task keeps same-name abilities from different schools" do
    Rulebuilder::StockSpell.where(core_rules: "Draw Steel").destroy_all

    Rake::Task["db:seed:draw_steel:abilities"].reenable
    Rake::Task["db:seed:draw_steel:abilities"].invoke

    records = JSON.parse(File.read(Rails.root.join("db", "seeds", "draw-steel", "abilities.json")))
    expected_count = records.uniq.size
    spells = Rulebuilder::StockSpell.where(core_rules: "Draw Steel")

    assert_equal expected_count, spells.count
    assert spells.exists?(name: "Blessing of Secrets", school: "Censor")
    assert spells.exists?(name: "Blessing of Secrets", school: "Conduit")
  end

  test "seed tasks store rendered HTML descriptions" do
    Rulebuilder::StockRule.where(core_rules: "Draw Steel", rule_type: "Ancestry").destroy_all
    Rulebuilder::StockSpell.where(core_rules: "Draw Steel").destroy_all

    Rake::Task["db:seed:draw_steel:ancestries"].reenable
    Rake::Task["db:seed:draw_steel:ancestries"].invoke

    Rake::Task["db:seed:draw_steel:abilities"].reenable
    Rake::Task["db:seed:draw_steel:abilities"].invoke

    rule = Rulebuilder::StockRule.find_by!(core_rules: "Draw Steel", rule_type: "Ancestry")
    spell = Rulebuilder::StockSpell.find_by!(core_rules: "Draw Steel")

    assert_match(/<h\d/, rule.full_description)
    assert_match(/<h\d/, spell.full_description)
    assert_no_match(/^##/, rule.full_description)
    assert_no_match(/^######/, spell.full_description)
  end

  test "draw steel seed namespace exposes aggregate task under db:seed" do
    assert Rake::Task.task_defined?("db:seed:draw_steel:all")
  end

  test "draw steel aggregate seed task explains that creatures are not seeded" do
    stdout, = capture_io do
      Rake::Task["db:seed:draw_steel:all"].reenable
      Rake::Task["db:seed:draw_steel:all"].invoke
    end

    assert_match(/does not seed stock creatures/i, stdout)
  end
end
