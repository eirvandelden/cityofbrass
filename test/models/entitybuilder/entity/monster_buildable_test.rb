require "test_helper"

module Entitybuilder
  class Entity
    class MonsterBuildableTest < ActiveSupport::TestCase
      SOLDIER = { monster_level: 5, monster_role: "Soldier", monster_group: "Standard",
monster_defense_bonuses: [] }.freeze

      def row(entity, kind, name)
        entity.reload.public_send(kind).find_by(name: name)
      end

      def inputs(**changes)
        SOLDIER.merge(changes)
      end

      class Validations < MonsterBuildableTest
        test "refuses the builder outside 4e" do
          creature = entitybuilder_entities(:resident_creature_pf2e)
          creature.assign_attributes(inputs)

          assert_not creature.valid?
          assert_predicate creature.errors, :any?
        end

        test "refuses level outside 1 to 40" do
          creature = entitybuilder_entities(:four_e_creature_unbuilt)

          [ 0, 41, -3 ].each do |level|
            creature.assign_attributes(inputs(monster_level: level))

            assert_not creature.valid?, "level #{level}"
            assert_predicate creature.errors[:monster_level], :any?
          end
          [ 1, 40 ].each do |level|
            creature.assign_attributes(inputs(monster_level: level))

            assert_predicate creature, :valid?, "level #{level}"
          end
        end

        test "refuses an unknown role or group" do
          creature = entitybuilder_entities(:four_e_creature_unbuilt)

          creature.assign_attributes(inputs(monster_role: "Leader"))

          assert_not creature.valid?
          assert_predicate creature.errors[:monster_role], :any?

          creature.assign_attributes(inputs(monster_group: "Legendary"))

          assert_not creature.valid?
          assert_predicate creature.errors[:monster_group], :any?
        end

        test "refuses level, role or group alone" do
          creature = entitybuilder_entities(:four_e_creature_unbuilt)

          { monster_level: 5, monster_role: "Soldier", monster_group: "Standard" }.each do |name, value|
            creature = Entity.find(creature.id)
            creature.assign_attributes(name => value)

            assert_not creature.valid?, name.to_s
          end
        end

        test "refuses more than two defense picks" do
          creature = entitybuilder_entities(:four_e_creature_unbuilt)
          creature.assign_attributes(inputs(monster_group: "Elite", monster_defense_bonuses: %w[Fortitude Reflex Will]))

          assert_not creature.valid?
          assert_predicate creature.errors[:monster_defense_bonuses], :any?
        end

        test "clears defense picks when the group becomes standard" do
          creature = entitybuilder_entities(:four_e_creature_unbuilt)
          creature.assign_attributes(inputs(monster_group: "Standard", monster_defense_bonuses: %w[Reflex Will]))

          assert_predicate creature, :valid?
          assert_empty creature.monster_defense_bonuses
        end

        test "unrelated entity updates skip builder validations" do
          creature = entitybuilder_entities(:four_e_creature_built)
          creature.update_columns(monster_level: 99)

          assert creature.update(name: "Renamed Orc")
        end
      end

      class Rebuilding < MonsterBuildableTest
        test "first opt-in fills untouched template rows" do
          creature = entitybuilder_entities(:four_e_creature_unbuilt)

          assert creature.rebuild_monster(inputs)

          assert_equal 21, row(creature, :defenses, "Armor Class").bonus
          assert_equal [ 17, 17, 17 ], %w[Fortitude Reflex Will].map { |name| row(creature, :defenses, name).bonus }
          assert_equal [ 64, 64 ], row(creature, :trackables, "Hit Points").then { |hp| [ hp.maximum, hp.current ] }
          assert_equal 0, row(creature, :trackables, "Action Points").maximum
          assert_equal 4, row(creature, :movements, "Initiative").base
          assert_equal %w[5 Soldier 200], %w[Level Role Experience].map { |name|
 row(creature, :descriptors, name).description }
          assert_nil row(creature, :saving_throws, "Saving Throws")
        end

        test "first opt-in keeps designed values and marks them" do
          creature = entitybuilder_entities(:four_e_creature_designed)

          creature.rebuild_monster(inputs)

          assert_equal 19, row(creature, :defenses, "Armor Class").base
          assert_nil row(creature, :defenses, "Armor Class").bonus
          assert_equal 40, row(creature, :trackables, "Hit Points").maximum
          assert_equal 17, row(creature, :defenses, "Fortitude").bonus
          assert_predicate creature.monster_values[:armor_class], :needs_manual_revision?
          assert_predicate creature.monster_values[:hit_points], :needs_manual_revision?
          assert_not creature.monster_values[:fortitude].needs_manual_revision?
        end

        test "rebuild keeps values that differ from the previous calculation" do
          creature = entitybuilder_entities(:four_e_creature_built)

          creature.rebuild_monster(inputs(monster_level: 6))

          assert_equal 23, row(creature, :defenses, "Armor Class").bonus
          assert_equal 18, row(creature, :defenses, "Fortitude").bonus
          assert_equal 72, row(creature, :trackables, "Hit Points").maximum
          assert_equal 5, row(creature, :movements, "Initiative").base
          assert_equal "6", row(creature, :descriptors, "Level").description
          assert_predicate creature.monster_values[:armor_class], :needs_manual_revision?
        end

        test "rebuild reads the previous inputs from the database" do
          creature = entitybuilder_entities(:four_e_creature_built)
          creature.monster_level = 6

          creature.rebuild_monster(inputs(monster_level: 6))

          assert_equal 18, row(creature, :defenses, "Fortitude").bonus
        end

        test "rebuild parses the previous defense picks from the database" do
          creature = entitybuilder_entities(:four_e_creature_unbuilt)
          creature.rebuild_monster(inputs(monster_group: "Elite", monster_defense_bonuses: %w[Reflex Will]))

          assert_equal 19, row(creature, :defenses, "Reflex").bonus

          Entity.find(creature.id).rebuild_monster(inputs(monster_group: "Elite", monster_defense_bonuses: %w[Will]))

          assert_equal 17, row(creature, :defenses, "Reflex").bonus
          assert_equal 19, row(creature, :defenses, "Will").bonus
        end

        test "npc opt-in adds missing rows and keeps paired character rows" do
          npc = entitybuilder_entities(:four_e_npc_unbuilt)

          npc.rebuild_monster(inputs)

          assert_equal 17, row(npc, :defenses, "Fortitude").bonus
          assert_equal 17, row(npc, :defenses, "Will").bonus
          assert row(npc, :defenses, "Fortitude (Str)")
          assert row(npc, :defenses, "Will (Cha)")
          assert_equal 21, row(npc, :defenses, "Armor Class").bonus
          assert_equal "5", row(npc, :descriptors, "Level").description
          assert_equal "Soldier", row(npc, :descriptors, "Role").description
        end

        test "stores the role descriptor in English under any locale" do
          creature = entitybuilder_entities(:four_e_creature_unbuilt)

          I18n.with_locale(:nl) { creature.rebuild_monster(inputs(monster_group: "Elite")) }

          assert_equal "Elite Soldier", row(creature, :descriptors, "Role").description
        end
      end

      class Values < MonsterBuildableTest
        test "needs manual revision when stored differs from calculated" do
          creature = entitybuilder_entities(:four_e_creature_built)
          armor_class = creature.monster_values[:armor_class]

          assert_equal 23, armor_class.stored
          assert_equal 21, armor_class.calculated
          assert_predicate armor_class, :needs_manual_revision?
          assert_not creature.monster_values[:fortitude].needs_manual_revision?
        end

        test "reset writes the calculated value" do
          creature = entitybuilder_entities(:four_e_creature_built)

          creature.reset_monster_value(:armor_class)

          assert_equal 21, row(creature, :defenses, "Armor Class").bonus
          assert_not creature.monster_values[:armor_class].needs_manual_revision?
        end

        test "a level outside 1 to 40 is not built" do
          creature = entitybuilder_entities(:four_e_creature_built)
          creature.monster_level = 41

          assert_not creature.monster_built?
          assert_empty creature.monster_values
        end

        test "a monster moved to another rule set is not built" do
          creature = entitybuilder_entities(:four_e_creature_built)
          creature.core_rules = "pf2e"

          assert_not creature.monster_built?
        end

        test "extra action defaults per group" do
          creature = entitybuilder_entities(:four_e_creature_unbuilt)

          creature.assign_attributes(inputs(monster_group: "Solo"))

          assert_predicate creature, :extra_action?
          assert_match(/additional standard action/i, creature.extra_action_label)

          creature.assign_attributes(inputs(monster_group: "Elite"))

          assert_not creature.extra_action?
          assert_match(/additional attack/i, creature.extra_action_label)

          creature.assign_attributes(inputs(monster_group: "Elite", monster_extra_action: true))

          assert_predicate creature, :extra_action?

          creature.assign_attributes(inputs(monster_group: "Standard", monster_extra_action: nil))

          assert_not creature.extra_action?
          assert_nil creature.extra_action_label
        end
      end
    end
  end
end
