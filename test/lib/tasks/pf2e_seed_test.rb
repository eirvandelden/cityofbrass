require "test_helper"
require "rake"

class Pf2eSeedTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("db:seed:pf2e:ancestries")
  end

  test "ancestries seed task creates StockRules with ORC attribution" do
    Rulebuilder::StockRule.where(core_rules: "Pathfinder 2e", rule_type: "Ancestry").destroy_all

    Rake::Task["db:seed:pf2e:ancestries"].reenable
    Rake::Task["db:seed:pf2e:ancestries"].invoke

    rules = Rulebuilder::StockRule.where(core_rules: "Pathfinder 2e", rule_type: "Ancestry")
    assert rules.count >= 10, "expected at least 10 ancestry records, got #{rules.count}"

    rules.each do |r|
      assert_equal "Paizo Inc.", r.publisher
      assert r.full_description.include?("ORC"), "expected ORC attribution in #{r.name}"
      assert r.is_shared, "expected is_shared=true on #{r.name}"
    end
  end

  test "seed task is idempotent — running twice does not duplicate" do
    Rulebuilder::StockRule.where(core_rules: "Pathfinder 2e", rule_type: "Condition").destroy_all

    Rake::Task["db:seed:pf2e:conditions"].reenable
    Rake::Task["db:seed:pf2e:conditions"].invoke
    first_count = Rulebuilder::StockRule.where(core_rules: "Pathfinder 2e", rule_type: "Condition").count

    Rake::Task["db:seed:pf2e:conditions"].reenable
    Rake::Task["db:seed:pf2e:conditions"].invoke
    second_count = Rulebuilder::StockRule.where(core_rules: "Pathfinder 2e", rule_type: "Condition").count

    assert_equal first_count, second_count, "seed should be idempotent"
  end

  test "spells seed preserves same-name spells across traditions (schools)" do
    # Fireball is in Arcane (and Primal); Heal appears in Divine and Primal
    Rulebuilder::StockSpell.where(core_rules: "Pathfinder 2e").destroy_all

    Rake::Task["db:seed:pf2e:spells"].reenable
    Rake::Task["db:seed:pf2e:spells"].invoke

    assert Rulebuilder::StockSpell.exists?(core_rules: "Pathfinder 2e", name: "Fireball", school: "Arcane"),
           "expected Fireball in Arcane tradition"

    # Heal should appear in multiple traditions (Divine and Primal at minimum)
    heal_records = Rulebuilder::StockSpell.where(core_rules: "Pathfinder 2e", name: "Heal")
    assert heal_records.count >= 2, "expected Heal in at least 2 traditions, got #{heal_records.map(&:school).inspect}"
  end

  test "seed tasks store rendered HTML descriptions (no raw markdown)" do
    Rulebuilder::StockRule.where(core_rules: "Pathfinder 2e", rule_type: "Ancestry").destroy_all

    Rake::Task["db:seed:pf2e:ancestries"].reenable
    Rake::Task["db:seed:pf2e:ancestries"].invoke

    rule = Rulebuilder::StockRule.find_by!(core_rules: "Pathfinder 2e", rule_type: "Ancestry")
    assert_no_match(/^##\s/, rule.full_description)
  end

  test "conditions seed task creates exactly 43 condition records" do
    Rulebuilder::StockRule.where(core_rules: "Pathfinder 2e", rule_type: "Condition").destroy_all

    Rake::Task["db:seed:pf2e:conditions"].reenable
    Rake::Task["db:seed:pf2e:conditions"].invoke

    count = Rulebuilder::StockRule.where(core_rules: "Pathfinder 2e", rule_type: "Condition").count
    assert_equal 43, count
  end
end
