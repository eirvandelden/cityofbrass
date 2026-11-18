require "test_helper"

module Entitybuilder
  class MonsterTargetTest < ActiveSupport::TestCase
    def target(key)
      MonsterTarget.fetch(key)
    end

    def row(entity, kind, name)
      entity.reload.public_send(kind).find_by(name: name)
    end

    test "creates a missing row by exact name" do
      creature = entitybuilder_entities(:resident_creature_one)

      target(:fortitude).write(creature, 17)

      defense = row(creature, :defenses, "Fortitude")

      assert_equal 17, defense.bonus
    end

    test "creates a missing armor class row first in the sort order" do
      creature = entitybuilder_entities(:resident_creature_one)
      Defense.create!(entity: creature, name: "Will", sort_order: 3, base: 12)
      Defense.create!(entity: creature, name: "Reflex", sort_order: 4, base: 12)

      target(:armor_class).write(creature, 21)

      assert_equal "Armor Class", creature.reload.defenses.first.name
      assert_equal 21, creature.defenses.first.bonus
    end

    test "gives a created defense row base 0" do
      creature = entitybuilder_entities(:resident_creature_one)

      target(:reflex).write(creature, 17)

      assert_equal 0, row(creature, :defenses, "Reflex").base
    end

    test "moves current hit points along only when unwounded" do
      unwounded = entitybuilder_entities(:resident_creature_one)
      wounded = entitybuilder_entities(:resident_creature_two)
      blank = entitybuilder_entities(:resident_creature_three)
      Trackable.create!(entity: unwounded, name: "Hit Points", sort_order: 0, maximum: 50, current: 50)
      Trackable.create!(entity: wounded, name: "Hit Points", sort_order: 0, maximum: 50, current: 20)
      Trackable.create!(entity: blank, name: "Hit Points", sort_order: 0, maximum: 50, current: nil)

      [ unwounded, wounded, blank ].each { |creature| target(:hit_points).write(creature, 64) }

      assert_equal [ 64, 64 ], row(unwounded, :trackables, "Hit Points").then { |hp| [ hp.maximum, hp.current ] }
      assert_equal [ 64, 20 ], row(wounded, :trackables, "Hit Points").then { |hp| [ hp.maximum, hp.current ] }
      assert_equal [ 64, 64 ], row(blank, :trackables, "Hit Points").then { |hp| [ hp.maximum, hp.current ] }
    end

    test "removes the saving throws row at 0" do
      creature = entitybuilder_entities(:resident_creature_one)

      target(:saving_throws).write(creature, 2)

      assert_equal 2, row(creature, :saving_throws, "Saving Throws").bonus

      target(:saving_throws).write(creature, 0)

      assert_nil row(creature, :saving_throws, "Saving Throws")
    end

    test "counts a missing saving throws row as 0" do
      creature = entitybuilder_entities(:four_e_creature_unbuilt)

      assert_equal 0, target(:saving_throws).stored(creature)
      assert_nil target(:armor_class).stored(Entity.find(entitybuilder_entities(:resident_creature_one).id))
    end

    test "treats a present initiative bonus as an edit" do
      creature = entitybuilder_entities(:four_e_creature_built)

      assert_not target(:initiative).edited?(creature, 4)

      row(creature, :movements, "Initiative").update!(bonus: 4)

      assert target(:initiative).edited?(creature.reload, 4)
    end

    test "recognises a row that still holds its template values" do
      untouched = entitybuilder_entities(:four_e_creature_unbuilt)
      designed = entitybuilder_entities(:four_e_creature_designed)
      missing = entitybuilder_entities(:resident_creature_one)

      assert target(:armor_class).untouched_template?(untouched)
      assert target(:hit_points).untouched_template?(untouched)
      assert target(:level).untouched_template?(untouched)
      assert target(:armor_class).untouched_template?(missing)
      assert_not target(:armor_class).untouched_template?(designed)
      assert_not target(:hit_points).untouched_template?(designed)
    end
  end
end
