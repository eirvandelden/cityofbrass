require 'test_helper'

module Entitybuilder
  class AttackTest < ActiveSupport::TestCase

    test "attack should have the necessary required validators" do
      attack = Attack.new(name: "AttackTest")
      assert_not attack.valid?
      assert_equal [:entity, :attack_type], attack.errors.attribute_names
    end

    def power(entity, **fields)
      entity.attacks.new({ name: "Power", attack_type: "Melee", power_usage: "Encounter" }.merge(fields))
    end

    test "refuses an unknown action type or power usage" do
      standard = entitybuilder_entities(:four_e_standard_level_3)

      assert_not power(standard, action_type: "Free").valid?
      assert_not power(standard, power_usage: "Daily").valid?
      assert_predicate power(standard, power_usage: nil), :valid?
    end

    test "refuses recharges when first bloodied on an at-will power" do
      elite = entitybuilder_entities(:four_e_elite_level_3)
      elite.attacks.destroy_all

      assert_not power(elite, power_usage: "At-will", recharges_when_bloodied: true).valid?
      assert_predicate power(elite, recharges_when_bloodied: true), :valid?
    end

    test "refuses usable at will outside a solo" do
      elite = entitybuilder_entities(:four_e_elite_level_3)

      assert_not power(elite, usable_at_will: true).valid?
    end

    test "refuses usable at will on an at-will power" do
      solo = entitybuilder_entities(:four_e_solo_level_3_open)

      assert_not power(solo, power_usage: "At-will", usable_at_will: true).valid?
    end

    test "a marked attack still saves a new sort order after a group change" do
      solo = entitybuilder_entities(:four_e_solo_level_3)
      marked = entitybuilder_attacks(:solo_marked_power)
      solo.update!(monster_group: "Standard")

      assert marked.reload.update(sort_order: 5)
      assert_equal 5, marked.reload.sort_order
    end

    test "reports a missing entity instead of raising for a marked attack" do
      attack = Attack.new(name: "Orphan", attack_type: "Melee", power_usage: "Encounter", recharges_when_bloodied: true)

      assert_not attack.valid?
      assert_includes attack.errors.attribute_names, :entity
    end

    test "power prefill options cover every usage and multi-target combination" do
      options = power(entitybuilder_entities(:four_e_brute_level_4)).power_prefill_options

      assert_equal 2 * 2 * 2, options.size
      assert_equal({ attack_bonus: 9, damage_bonus: 15 }, options.fetch([ "At-will", false, false ]))
      assert_equal({ attack_bonus: 9, damage_bonus: 18 }, options.fetch([ "Encounter", false, false ]))
    end

    test "usable at will prefills at-will damage" do
      options = power(entitybuilder_entities(:four_e_solo_level_3_open)).power_prefill_options

      assert_equal 13, options.fetch([ "Encounter", false, true ]).fetch(:damage_bonus)
    end

    test "has no prefill options for an unbuilt monster" do
      assert_empty power(entitybuilder_entities(:four_e_creature_unbuilt)).power_prefill_options
    end
  end
end
