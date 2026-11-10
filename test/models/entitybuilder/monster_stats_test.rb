require "test_helper"

module Entitybuilder
  class MonsterStatsTest < ActiveSupport::TestCase
    def stats(level: 5, role: "Soldier", group: "Standard", defense_bonuses: [])
      MonsterStats.new(level: level, role: role, group: group, defense_bonuses: defense_bonuses)
    end

    test "armor class adjusts for soldier, brute and artillery" do
      assert_equal 21, stats(role: "Soldier").armor_class
      assert_equal 17, stats(role: "Brute").armor_class
      assert_equal 17, stats(role: "Artillery").armor_class
      assert_equal 19, stats(role: "Controller").armor_class
      assert_equal 19, stats(role: "Lurker").armor_class
      assert_equal 19, stats(role: "Skirmisher").armor_class
      assert_equal 15, stats(level: 3, role: "Brute").armor_class
    end

    test "elite and solo add 2 to armor class" do
      assert_equal 21, stats(level: 3, role: "Soldier", group: "Elite").armor_class
      assert_equal 17, stats(level: 3, role: "Brute", group: "Solo").armor_class
      assert_equal 21, stats(role: "Soldier", group: "Standard").armor_class
    end

    test "picked defenses gain 2 only for elite and solo" do
      elite = stats(level: 3, group: "Elite", defense_bonuses: %w[Reflex Will])

      assert_equal 15, elite.fortitude
      assert_equal 17, elite.reflex
      assert_equal 17, elite.will
      assert_equal 17, stats(level: 3, group: "Solo", defense_bonuses: %w[Fortitude]).fortitude
      assert_equal 17, stats(group: "Standard", defense_bonuses: %w[Reflex]).reflex
      assert_equal 17, stats(group: "Minion", defense_bonuses: %w[Will]).will
    end

    test "hit points per role" do
      assert_equal 64, stats(role: "Soldier").hit_points
      assert_equal 64, stats(role: "Skirmisher").hit_points
      assert_equal 64, stats(role: "Controller").hit_points
      assert_equal 56, stats(level: 3, role: "Brute").hit_points
      assert_equal 51, stats(level: 5, role: "Artillery").hit_points
      assert_equal 39, stats(level: 3, role: "Lurker").hit_points
    end

    test "elite doubles and solo quadruples hit points" do
      assert_equal 78, stats(level: 3, role: "Lurker", group: "Elite").hit_points
      assert_equal 160, stats(level: 2, role: "Controller", group: "Solo").hit_points
    end

    test "minion has 1 hit point" do
      assert_equal 1, stats(group: "Minion").hit_points
      assert_equal 1, stats(level: 40, role: "Brute", group: "Minion").hit_points
    end

    test "saving throw bonus and action points per group" do
      assert_equal [ 0, 0 ], [ stats(group: "Minion").saving_throw_bonus, stats(group: "Minion").action_points ]
      assert_equal [ 0, 0 ], [ stats(group: "Standard").saving_throw_bonus, stats(group: "Standard").action_points ]
      assert_equal [ 2, 1 ], [ stats(group: "Elite").saving_throw_bonus, stats(group: "Elite").action_points ]
      assert_equal [ 5, 2 ], [ stats(group: "Solo").saving_throw_bonus, stats(group: "Solo").action_points ]
    end

    test "initiative base is half level plus role bonus" do
      assert_equal 4, stats(level: 5, role: "Soldier").initiative_base
      assert_equal 5, stats(level: 4, role: "Lurker").initiative_base
      assert_equal 2, stats(level: 4, role: "Brute").initiative_base
      assert_equal 4, stats(level: 4, role: "Skirmisher").initiative_base
      assert_equal 3, stats(level: 7, role: "Controller").initiative_base
      assert_equal 3, stats(level: 7, role: "Artillery").initiative_base
    end

    test "attack bonus is 5 plus level and average damage is 8 plus level" do
      assert_equal 10, stats(level: 5).attack_bonus
      assert_equal 13, stats(level: 5).average_damage
    end

    test "experience per group uses the table" do
      assert_equal 200, stats(level: 5, group: "Standard").experience
      assert_equal 400, stats(level: 5, group: "Elite").experience
      assert_equal 1000, stats(level: 5, group: "Solo").experience
      assert_equal 555_000, stats(level: 40, group: "Solo").experience
    end

    test "refuses a level outside 1 to 40" do
      [ 0, 41 ].each do |level|
        assert_raises(ArgumentError) { stats(level: level) }
      end
    end

    test "minion experience uses the rounded table values" do
      assert_equal 31, stats(level: 2, group: "Minion").experience
      assert_equal 38, stats(level: 3, group: "Minion").experience
      assert_equal 1038, stats(level: 22, group: "Minion").experience
    end

    test "power damage multiplies adjustments and rounds down once" do
      assert_equal 11, stats(level: 3).power_damage(usage: :at_will, multi_target: false)
      assert_equal 13, stats(level: 3).power_damage(usage: :encounter, multi_target: false)
      assert_equal 8, stats(level: 3).power_damage(usage: :at_will, multi_target: true)
      assert_equal 10, stats(level: 3).power_damage(usage: :encounter, multi_target: true)
      assert_equal 13, stats(level: 3, role: "Brute").power_damage(usage: :at_will, multi_target: false)
      assert_equal 17, stats(level: 3, role: "Brute").power_damage(usage: :encounter, multi_target: false)
      assert_equal 5, stats(level: 3, group: "Minion").power_damage(usage: :at_will, multi_target: false)
    end

    test "role label combines group and role" do
      assert_equal "Elite Soldier", stats(role: "Soldier", group: "Elite").role_label
      assert_equal "Solo Brute", stats(role: "Brute", group: "Solo").role_label
      assert_equal "Minion Artillery", stats(role: "Artillery", group: "Minion").role_label
      assert_equal "Soldier", stats(role: "Soldier", group: "Standard").role_label
    end
  end
end
