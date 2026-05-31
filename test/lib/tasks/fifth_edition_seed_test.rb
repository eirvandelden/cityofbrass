require "test_helper"
require "rake"

class FifthEditionSeedTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("db:seed:5e:classes")
  end

  test "classes seed task creates valid StockRules with normalized source fields" do
    Rulebuilder::StockRule.where(core_rules: "5th Edition", rule_type: "Class").destroy_all

    run_task("db:seed:5e:classes")

    rules = Rulebuilder::StockRule.where(core_rules: "5th Edition", rule_type: "Class")
    assert_equal 12, rules.count
    assert rules.all?(&:valid?), "expected seeded class records to be valid"

    barbarian = rules.find_by!(name: "Barbarian")
    assert_equal "Wizards of the Coast LLC", barbarian.publisher
    assert_equal "SRD 5.2.1", barbarian.source
    assert_match(/Creative Commons Attribution 4\.0 International License/, barbarian.full_description)
  end

  test "spells seed task is idempotent" do
    Rulebuilder::StockSpell.where(core_rules: "5th Edition").destroy_all

    run_task("db:seed:5e:spells")
    first_count = Rulebuilder::StockSpell.where(core_rules: "5th Edition").count

    run_task("db:seed:5e:spells")
    second_count = Rulebuilder::StockSpell.where(core_rules: "5th Edition").count

    assert_equal first_count, second_count
  end

  test "seed tasks store rendered HTML descriptions" do
    Rulebuilder::StockRule.where(core_rules: "5th Edition", rule_type: "Species").destroy_all
    Rulebuilder::StockRule.where(core_rules: "5th Edition", rule_type: "Backgrounds").destroy_all
    Rulebuilder::StockSpell.where(core_rules: "5th Edition").destroy_all
    Rulebuilder::StockItem.where(core_rules: "5th Edition").destroy_all

    run_task("db:seed:5e:species")
    run_task("db:seed:5e:backgrounds")
    run_task("db:seed:5e:spells")
    run_task("db:seed:5e:items")

    species = Rulebuilder::StockRule.find_by!(core_rules: "5th Edition", rule_type: "Species", name: "Elf")
    background = Rulebuilder::StockRule.find_by!(
      core_rules: "5th Edition",
      rule_type: "Backgrounds",
      name: "Acolyte"
    )
    spell = Rulebuilder::StockSpell.find_by!(core_rules: "5th Edition", name: "Acid Splash")
    item = Rulebuilder::StockItem.find_by!(core_rules: "5th Edition", name: "Club")

    [ species, background, spell, item ].each do |record|
      assert_match(/<h\d/, record.full_description)
      assert_no_match(/^#/, record.full_description)
      assert_equal "Wizards of the Coast LLC", record.publisher
      assert_equal "SRD 5.2.1", record.source
    end
  end

  test "creature and animal seed tasks create valid StockCreatures and stay idempotent" do
    Entitybuilder::StockCreature.where(core_rules: "5th Edition").destroy_all

    run_task("db:seed:5e:creatures")
    run_task("db:seed:5e:animals")

    monster = Entitybuilder::StockCreature.find_by!(core_rules: "5th Edition", name: "Adult Black Dragon")
    animal = Entitybuilder::StockCreature.find_by!(core_rules: "5th Edition", name: "Ape")

    [ monster, animal ].each do |creature|
      assert creature.valid?, "expected #{creature.name} to be valid"
      assert_equal "Wizards of the Coast LLC", creature.publisher
      assert_equal "SRD 5.2.1", creature.source
      assert_match(/<h\d|<p>/, creature.full_description)
      assert creature.ability_scores.any?, "expected ability scores on #{creature.name}"
      assert creature.descriptors.any?, "expected descriptors on #{creature.name}"
      assert creature.trackables.any?, "expected trackables on #{creature.name}"
    end

    first_snapshot = snapshot_creature(monster)

    run_task("db:seed:5e:creatures")
    run_task("db:seed:5e:animals")

    second_snapshot = snapshot_creature(
      Entitybuilder::StockCreature.find_by!(core_rules: "5th Edition", name: "Adult Black Dragon")
    )

    assert_equal first_snapshot, second_snapshot
  end

  test "creature seed task normalizes ranged attacks to the app range bucket" do
    Entitybuilder::StockCreature.where(core_rules: "5th Edition").destroy_all

    run_task("db:seed:5e:creatures")

    assassin = Entitybuilder::StockCreature.find_by!(core_rules: "5th Edition", name: "Assassin")

    assert assassin.attacks.exists?(attack_type: "Range")
    assert_not assassin.attacks.exists?(attack_type: "Ranged")
  end

  test "all seed categories provide spot-check records" do
    Rulebuilder::StockRule.where(core_rules: "5th Edition").destroy_all
    Rulebuilder::StockSpell.where(core_rules: "5th Edition").destroy_all
    Rulebuilder::StockItem.where(core_rules: "5th Edition").destroy_all
    Entitybuilder::StockCreature.where(core_rules: "5th Edition").destroy_all

    %w[
      db:seed:5e:classes
      db:seed:5e:backgrounds
      db:seed:5e:species
      db:seed:5e:feats
      db:seed:5e:conditions
      db:seed:5e:spells
      db:seed:5e:items
      db:seed:5e:creatures
      db:seed:5e:animals
    ].each { |task_name| run_task(task_name) }

    assert Rulebuilder::StockRule.exists?(core_rules: "5th Edition", rule_type: "Class", name: "Barbarian")
    assert Rulebuilder::StockRule.exists?(core_rules: "5th Edition", rule_type: "Backgrounds", name: "Acolyte")
    assert Rulebuilder::StockRule.exists?(core_rules: "5th Edition", rule_type: "Species", name: "Elf")
    assert Rulebuilder::StockRule.exists?(core_rules: "5th Edition", rule_type: "Feat", name: "Alert")
    assert Rulebuilder::StockRule.exists?(core_rules: "5th Edition", rule_type: "Condition", name: "Blinded")
    assert Rulebuilder::StockSpell.exists?(core_rules: "5th Edition", name: "Acid Splash")
    assert Rulebuilder::StockItem.exists?(core_rules: "5th Edition", name: "Club")
    assert Entitybuilder::StockCreature.exists?(core_rules: "5th Edition", name: "Adult Black Dragon")
    assert Entitybuilder::StockCreature.exists?(core_rules: "5th Edition", name: "Ape")
  end

  test "5e seed namespace exposes aggregate task under db:seed" do
    assert Rake::Task.task_defined?("db:seed:5e:all")
  end

  private
    def run_task(task_name)
      Rake::Task[task_name].reenable
      Rake::Task[task_name].invoke
    end

    def snapshot_creature(creature)
      {
        descriptors: creature.descriptors.pluck(:name, :description),
        ability_scores: creature.ability_scores.pluck(:name, :base, :modifier),
        movements: creature.movements.pluck(:name, :base, :description),
        trackables: creature.trackables.pluck(:name, :maximum, :current),
        saving_throws: creature.saving_throws.pluck(:name, :base, :ability_score),
        skills: creature.skills.pluck(:name, :bonus, :ability_score),
        attacks: creature.attacks.pluck(:name, :attack_type, :attack_range, :attack_bonus, :damage_dice, :damage_bonus),
        short_description: creature.short_description,
        full_description: creature.full_description
      }
    end
end
