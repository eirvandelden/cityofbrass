require "test_helper"
require "rake"

class DbSeedTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("db:seed")
  end

  test "db:seed invokes stock system seed aggregates" do
    User.where(email: "user@example.com").delete_all
    Admin.where(email: "user@example.com").delete_all
    Rulebuilder::StockRule.where(core_rules: [ "5th Edition", "Draw Steel" ]).delete_all
    Rulebuilder::StockSpell.where(core_rules: [ "5th Edition", "Draw Steel" ]).delete_all
    Rulebuilder::StockItem.where(core_rules: "5th Edition").delete_all
    Entitybuilder::StockCreature.where(core_rules: "5th Edition").delete_all

    Rake::Task["db:seed"].reenable
    Rake::Task["db:seed"].invoke

    assert Rulebuilder::StockRule.exists?(core_rules: "5th Edition", rule_type: "Class", name: "Barbarian")
    assert Rulebuilder::StockRule.exists?(core_rules: "Draw Steel", rule_type: "Ancestry", name: "Devil")
    assert Rulebuilder::StockSpell.exists?(core_rules: "5th Edition", name: "Acid Splash")
    assert Rulebuilder::StockSpell.exists?(core_rules: "Draw Steel", name: "Blessing of Secrets")
    assert Rulebuilder::StockItem.exists?(core_rules: "5th Edition", name: "Club")
    assert Entitybuilder::StockCreature.exists?(core_rules: "5th Edition", name: "Adult Black Dragon")
  end
end
