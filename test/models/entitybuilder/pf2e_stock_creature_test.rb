require "test_helper"
require "rake"

class Pf2eStockCreatureTest < ActiveSupport::TestCase
  SAMPLE_SEED_FILE = Rails.root.join("db", "seeds", "pf2e", "creatures-sample.json")

  setup do
    destroy_pf2e_creatures
    seed_sample_creatures
  end

  test "sample creatures are seeded (10 creatures)" do
    count = Entitybuilder::StockCreature.where(core_rules: "pf2e").count
    assert_equal 10, count
  end

  test "each creature has exactly 6 ability scores" do
    Entitybuilder::StockCreature.where(core_rules: "pf2e").each do |c|
      assert_equal 6, c.ability_scores.count, "#{c.name} should have 6 ability scores"
      names = c.ability_scores.map(&:name)
      %w[Strength Dexterity Constitution Intelligence Wisdom Charisma].each do |n|
        assert_includes names, n, "#{c.name} missing ability score #{n}"
      end
    end
  end

  test "each creature has Hit Points trackable" do
    Entitybuilder::StockCreature.where(core_rules: "pf2e").each do |c|
      assert c.trackables.exists?(name: "Hit Points"), "#{c.name} missing Hit Points"
    end
  end

  test "each creature has Armor Class defense" do
    Entitybuilder::StockCreature.where(core_rules: "pf2e").each do |c|
      assert c.defenses.exists?(name: "Armor Class"), "#{c.name} missing Armor Class"
    end
  end

  test "each creature has Fort, Reflex, Will saving throws" do
    Entitybuilder::StockCreature.where(core_rules: "pf2e").each do |c|
      save_names = c.saving_throws.map(&:name)
      assert_includes save_names, "Fortitude", "#{c.name} missing Fortitude"
      assert_includes save_names, "Reflex",    "#{c.name} missing Reflex"
      assert_includes save_names, "Will",      "#{c.name} missing Will"
    end
  end

  test "each creature has Level and Proficiency Bonus base values" do
    Entitybuilder::StockCreature.where(core_rules: "pf2e").each do |c|
      bv_names = c.base_values.map(&:name)
      assert_includes bv_names, "Level",             "#{c.name} missing Level"
      assert_includes bv_names, "Proficiency Bonus", "#{c.name} missing Proficiency Bonus"
    end
  end

  test "creature seeding is idempotent — re-seeding preserves child-row counts" do
    counts_before = creature_child_counts
    seed_sample_creatures
    counts_after = creature_child_counts

    assert_equal counts_before, counts_after, "re-seeding should not change child row counts"
  end

  private

  def creature_child_counts
    pf2e_creatures.map do |creature|
      [creature.name, child_counts_for(creature)]
    end.to_h
  end

  def child_counts_for(creature)
    {
      ability_scores: creature.ability_scores.count,
      trackables: creature.trackables.count,
      defenses: creature.defenses.count,
      saving_throws: creature.saving_throws.count,
      attacks: creature.attacks.count
    }
  end

  def destroy_pf2e_creatures
    pf2e_creatures.each do |creature|
      destroy_creature(creature)
    end
  end

  def destroy_creature(creature)
    clear_creature_children(creature)
    creature.destroy
  end

  def pf2e_creatures
    Entitybuilder::StockCreature.where(core_rules: "pf2e")
  end

  def sample_records
    JSON.parse(File.read(SAMPLE_SEED_FILE))
  end

  def seed_sample_creatures
    sample_records.each do |attrs|
      creature = find_or_build_creature(attrs)
      assign_creature_attributes(creature, attrs)
      rebuild_creature_children(creature, attrs)
      creature.save!
    end
  end

  def find_or_build_creature(attrs)
    Entitybuilder::StockCreature.find_or_initialize_by(
      name: attrs["name"],
      core_rules: attrs["core_rules"]
    ) { |creature| creature.id = SecureRandom.uuid }
  end

  def assign_creature_attributes(creature, attrs)
    creature.assign_attributes(
      attrs.slice("short_description", "full_description", "publisher", "source", "is_3pp")
    )
    creature.save!
  end

  def rebuild_creature_children(creature, attrs)
    clear_creature_children(creature)
    build_ability_scores(creature, attrs["ability_scores"])
    build_trackables(creature, attrs["trackables"])
    build_base_values(creature, attrs["base_values"])
    build_defenses(creature, attrs["defenses"])
    build_saving_throws(creature, attrs["saving_throws"])
    build_attacks(creature, attrs["attacks"])
  end

  def clear_creature_children(creature)
    creature.ability_scores.delete_all
    creature.trackables.delete_all
    creature.base_values.delete_all
    creature.defenses.delete_all
    creature.saving_throws.delete_all
    creature.attacks.delete_all
  end

  def build_ability_scores(creature, ability_scores)
    Array(ability_scores).each do |attrs|
      creature.ability_scores.build(
        name: attrs["name"],
        base: attrs["base"].to_i,
        modifier: attrs["modifier"].to_i,
        dice: attrs["dice"].presence
      )
    end
  end

  def build_trackables(creature, trackables)
    Array(trackables).each do |attrs|
      creature.trackables.build(
        name: attrs["name"],
        maximum: attrs["maximum"].to_i,
        current: attrs["current"].to_i
      )
    end
  end

  def build_base_values(creature, base_values)
    Array(base_values).each do |attrs|
      creature.base_values.build(
        name: attrs["name"],
        value: attrs["value"].to_i,
        dice: attrs["dice"].presence
      )
    end
  end

  def build_defenses(creature, defenses)
    Array(defenses).each do |attrs|
      creature.defenses.build(
        name: attrs["name"],
        base: attrs["base"].to_i,
        ability_score: attrs["ability_score"]
      )
    end
  end

  def build_saving_throws(creature, saving_throws)
    Array(saving_throws).each do |attrs|
      creature.saving_throws.build(
        name: attrs["name"],
        base: attrs["base"].to_i,
        ability_score: attrs["ability_score"]
      )
    end
  end

  def build_attacks(creature, attacks)
    Array(attacks).each do |attrs|
      creature.attacks.build(
        name: attrs["name"],
        attack_type: attrs["attack_type"],
        attack_ability_score: attrs["attack_ability_score"],
        description: attrs["description"]
      )
    end
  end
end
