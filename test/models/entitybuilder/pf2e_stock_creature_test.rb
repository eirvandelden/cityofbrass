require "test_helper"
require "rake"

class Pf2eStockCreatureTest < ActiveSupport::TestCase
  SAMPLE_SEED_FILE = Rails.root.join("db", "seeds", "pf2e", "creatures-sample.json")

  setup do
    # Clean up any existing PF2e stock creatures from prior runs
    Entitybuilder::StockCreature.where(core_rules: "Pathfinder 2e").each do |c|
      c.ability_scores.delete_all
      c.trackables.delete_all
      c.base_values.delete_all
      c.defenses.delete_all
      c.saving_throws.delete_all
      c.attacks.delete_all
      c.destroy
    end

    # Seed from the small sample file
    records = JSON.parse(File.read(SAMPLE_SEED_FILE))
    records.each do |attrs|
      creature = Entitybuilder::StockCreature.find_or_initialize_by(
        name:       attrs["name"],
        core_rules: attrs["core_rules"]
      ) { |c| c.id = SecureRandom.uuid }

      creature.assign_attributes(attrs.slice(
        "short_description", "full_description", "publisher", "source", "is_3pp"
      ))
      creature.save!

      creature.ability_scores.delete_all
      creature.trackables.delete_all
      creature.base_values.delete_all
      creature.defenses.delete_all
      creature.saving_throws.delete_all
      creature.attacks.delete_all

      Array(attrs["ability_scores"]).each do |as_attrs|
        creature.ability_scores.build(
          name:     as_attrs["name"],
          base:     as_attrs["base"].to_i,
          modifier: as_attrs["modifier"].to_i,
          dice:     as_attrs["dice"].presence
        )
      end
      Array(attrs["trackables"]).each do |t_attrs|
        creature.trackables.build(
          name:    t_attrs["name"],
          maximum: t_attrs["maximum"].to_i,
          current: t_attrs["current"].to_i
        )
      end
      Array(attrs["base_values"]).each do |bv_attrs|
        creature.base_values.build(
          name:  bv_attrs["name"],
          value: bv_attrs["value"].to_i,
          dice:  bv_attrs["dice"].presence
        )
      end
      Array(attrs["defenses"]).each do |d_attrs|
        creature.defenses.build(
          name:          d_attrs["name"],
          base:          d_attrs["base"].to_i,
          ability_score: d_attrs["ability_score"]
        )
      end
      Array(attrs["saving_throws"]).each do |st_attrs|
        creature.saving_throws.build(
          name:          st_attrs["name"],
          base:          st_attrs["base"].to_i,
          ability_score: st_attrs["ability_score"]
        )
      end
      Array(attrs["attacks"]).each do |atk_attrs|
        creature.attacks.build(
          name:                 atk_attrs["name"],
          attack_type:          atk_attrs["attack_type"],
          attack_ability_score: atk_attrs["attack_ability_score"],
          description:          atk_attrs["description"]
        )
      end
      creature.save!
    end
  end

  test "sample creatures are seeded (10 creatures)" do
    count = Entitybuilder::StockCreature.where(core_rules: "Pathfinder 2e").count
    assert_equal 10, count
  end

  test "each creature has exactly 6 ability scores" do
    Entitybuilder::StockCreature.where(core_rules: "Pathfinder 2e").each do |c|
      assert_equal 6, c.ability_scores.count, "#{c.name} should have 6 ability scores"
      names = c.ability_scores.map(&:name)
      %w[Strength Dexterity Constitution Intelligence Wisdom Charisma].each do |n|
        assert_includes names, n, "#{c.name} missing ability score #{n}"
      end
    end
  end

  test "each creature has Hit Points trackable" do
    Entitybuilder::StockCreature.where(core_rules: "Pathfinder 2e").each do |c|
      assert c.trackables.exists?(name: "Hit Points"), "#{c.name} missing Hit Points"
    end
  end

  test "each creature has Armor Class defense" do
    Entitybuilder::StockCreature.where(core_rules: "Pathfinder 2e").each do |c|
      assert c.defenses.exists?(name: "Armor Class"), "#{c.name} missing Armor Class"
    end
  end

  test "each creature has Fort, Reflex, Will saving throws" do
    Entitybuilder::StockCreature.where(core_rules: "Pathfinder 2e").each do |c|
      save_names = c.saving_throws.map(&:name)
      assert_includes save_names, "Fortitude", "#{c.name} missing Fortitude"
      assert_includes save_names, "Reflex",    "#{c.name} missing Reflex"
      assert_includes save_names, "Will",      "#{c.name} missing Will"
    end
  end

  test "each creature has Level and Proficiency Bonus base values" do
    Entitybuilder::StockCreature.where(core_rules: "Pathfinder 2e").each do |c|
      bv_names = c.base_values.map(&:name)
      assert_includes bv_names, "Level",             "#{c.name} missing Level"
      assert_includes bv_names, "Proficiency Bonus", "#{c.name} missing Proficiency Bonus"
    end
  end

  test "creature seeding is idempotent — re-seeding preserves child-row counts" do
    # Record counts before re-seed
    counts_before = Entitybuilder::StockCreature.where(core_rules: "Pathfinder 2e").map do |c|
      [c.name, {
        ability_scores: c.ability_scores.count,
        trackables:     c.trackables.count,
        defenses:       c.defenses.count,
        saving_throws:  c.saving_throws.count,
        attacks:        c.attacks.count
      }]
    end.to_h

    # Re-seed
    records = JSON.parse(File.read(SAMPLE_SEED_FILE))
    records.each do |attrs|
      creature = Entitybuilder::StockCreature.find_or_initialize_by(
        name:       attrs["name"],
        core_rules: attrs["core_rules"]
      ) { |c| c.id = SecureRandom.uuid }
      creature.assign_attributes(attrs.slice(
        "short_description", "full_description", "publisher", "source", "is_3pp"
      ))
      creature.save!
      creature.ability_scores.delete_all
      creature.trackables.delete_all
      creature.base_values.delete_all
      creature.defenses.delete_all
      creature.saving_throws.delete_all
      creature.attacks.delete_all
      Array(attrs["ability_scores"]).each do |a|
        creature.ability_scores.build(name: a["name"], base: a["base"].to_i, modifier: a["modifier"].to_i, dice: a["dice"].presence)
      end
      Array(attrs["trackables"]).each do |t|
        creature.trackables.build(name: t["name"], maximum: t["maximum"].to_i, current: t["current"].to_i)
      end
      Array(attrs["base_values"]).each do |b|
        creature.base_values.build(name: b["name"], value: b["value"].to_i, dice: b["dice"].presence)
      end
      Array(attrs["defenses"]).each do |d|
        creature.defenses.build(name: d["name"], base: d["base"].to_i, ability_score: d["ability_score"])
      end
      Array(attrs["saving_throws"]).each do |s|
        creature.saving_throws.build(name: s["name"], base: s["base"].to_i, ability_score: s["ability_score"])
      end
      Array(attrs["attacks"]).each do |a|
        creature.attacks.build(name: a["name"], attack_type: a["attack_type"], attack_ability_score: a["attack_ability_score"], description: a["description"])
      end
      creature.save!
    end

    # Verify counts unchanged
    counts_after = Entitybuilder::StockCreature.where(core_rules: "Pathfinder 2e").map do |c|
      [c.name, {
        ability_scores: c.ability_scores.count,
        trackables:     c.trackables.count,
        defenses:       c.defenses.count,
        saving_throws:  c.saving_throws.count,
        attacks:        c.attacks.count
      }]
    end.to_h

    assert_equal counts_before, counts_after, "re-seeding should not change child row counts"
  end
end
