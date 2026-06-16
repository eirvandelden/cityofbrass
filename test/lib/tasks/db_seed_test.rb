require "test_helper"
require "rake"

class DbSeedTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("db:seed")
  end

  test "db:seed invokes stock system seed aggregates" do
    User.where(email: "user@example.com").delete_all
    Admin.where(email: "user@example.com").delete_all
    Rulebuilder::StockRule.where(core_rules: [ "dnd5e", "drawSteel" ]).delete_all
    Rulebuilder::StockSpell.where(core_rules: [ "dnd5e", "drawSteel" ]).delete_all
    Rulebuilder::StockItem.where(core_rules: "dnd5e").delete_all
    Entitybuilder::StockCreature.where(core_rules: "dnd5e").delete_all

    Rake::Task["db:seed"].reenable
    Rake::Task["db:seed"].invoke

    assert Rulebuilder::StockRule.exists?(core_rules: "dnd5e", rule_type: "Class", name: "Barbarian")
    assert Rulebuilder::StockRule.exists?(core_rules: "drawSteel", rule_type: "Ancestry", name: "Devil")
    assert Rulebuilder::StockSpell.exists?(core_rules: "dnd5e", name: "Acid Splash")
    assert Rulebuilder::StockSpell.exists?(core_rules: "drawSteel", name: "Blessing of Secrets")
    assert Rulebuilder::StockItem.exists?(core_rules: "dnd5e", name: "Club")
    assert Entitybuilder::StockCreature.exists?(core_rules: "dnd5e", name: "Adult Black Dragon")
  end
end
