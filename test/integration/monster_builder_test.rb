require "test_helper"

class MonsterBuilderTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:dan)
  end

  def builder_path(creature)
    "/eb/resident/creatures/#{creature.id}/monster_build"
  end

  def build(creature, level:, role:, group:, picks: [], extra_action: nil, values: {})
    patch builder_path(creature), params: { resident_creature: {
      monster_level: level, monster_role: role, monster_group: group, monster_defense_bonuses: picks,
      monster_extra_action: extra_action, monster_values: values
    }.compact }
    Entitybuilder::Entity.find(creature.id)
  end

  def build_soldier(creature = entitybuilder_entities(:four_e_creature_unbuilt), **changes)
    build(creature, **{ level: 5, role: "Soldier", group: "Standard" }.merge(changes))
  end

  def sheet(creature)
    get "/eb/resident/creatures/#{creature.id}/sheet"

    assert_response :success
  end

  def defense_bonus(creature, name)
    creature.defenses.find_by(name: name).bonus
  end

  def hit_points(creature)
    creature.trackables.find_by(name: "Hit Points").then { |hp| [ hp.maximum, hp.current ] }
  end

  def initiative(creature)
    creature.movements.find_by(name: "Initiative")
      .calculated_bonus(creature.ability_scores, creature.modifiers, creature.base_values)
  end

  test "level 5 standard soldier shows its card numbers" do
    creature = build_soldier

    assert_redirected_to "#{builder_path(creature)}/edit"
    sheet(creature)

    assert_select ".sheet-over-big", text: "21"
    assert_select "tr.roll", text: /Fortitude\s+17/
    assert_select "tr.roll", text: /Reflex\s+17/
    assert_select "tr.roll", text: /Will\s+17/
    assert_equal [ 64, 64, 4 ], hit_points(creature) + [ initiative(creature) ]
    descriptors = %w[Level Role Experience].map { |name| creature.descriptors.find_by(name: name).description }

    assert_equal %w[5 Soldier 200], descriptors
  end

  test "level 4 lurker with dexterity 14 shows initiative 7" do
    creature = build(entitybuilder_entities(:four_e_creature_dex14), level: 4, role: "Lurker", group: "Standard")

    assert_equal 7, initiative(creature)
  end

  test "level 4 brute shows initiative 2" do
    creature = build_soldier(level: 4, role: "Brute")

    assert_equal 2, initiative(creature)
  end

  test "level 3 elite soldier shows armor class 21" do
    creature = build_soldier(level: 3, group: "Elite")

    sheet(creature)

    assert_select ".sheet-over-big", text: "21"
  end

  test "elite with reflex and will picked raises only those two" do
    creature = build_soldier(level: 3, group: "Elite", picks: %w[Reflex Will])

    sheet(creature)

    assert_select "tr.roll", text: /Fortitude\s+15/
    assert_select "tr.roll", text: /Reflex\s+17/
    assert_select "tr.roll", text: /Will\s+17/
  end

  test "level 3 elite shows saving throws 2 and one action point" do
    creature = build_soldier(level: 3, group: "Elite")

    assert_equal 2, creature.saving_throws.find_by(name: "Saving Throws").bonus
    assert_equal 1, creature.trackables.find_by(name: "Action Points").maximum
    sheet(creature)

    assert_select "tr.roll", text: /Saving Throws/
  end

  test "level 3 solo shows saving throws 5 and two action points" do
    creature = build_soldier(level: 3, group: "Solo")

    assert_equal 5, creature.saving_throws.find_by(name: "Saving Throws").bonus
    assert_equal 2, creature.trackables.find_by(name: "Action Points").maximum
  end

  test "level 3 standard shows no saving throws and no action points" do
    creature = build_soldier(level: 3, group: "Standard")

    assert_nil creature.saving_throws.find_by(name: "Saving Throws")
    assert_equal 0, creature.trackables.find_by(name: "Action Points").maximum
    sheet(creature)

    assert_select "tr.roll", text: /Saving Throws/, count: 0
  end

  test "solo extra action defaults on and elite extra action defaults off" do
    get "#{builder_path(entitybuilder_entities(:four_e_creature_unbuilt))}/edit"

    assert_select "select[name=?] option[selected][value='']", "resident_creature[monster_extra_action]"

    solo = build_soldier(entitybuilder_entities(:four_e_creature_unbuilt), level: 3, group: "Solo", extra_action: "")
    elite = build_soldier(entitybuilder_entities(:four_e_creature_dex14), level: 3, group: "Elite", extra_action: "")

    sheet(solo)

    assert_select "body", text: /additional standard action/i

    sheet(elite)

    assert_select "p", text: /additional attack/i, count: 0

    solo_later = build_soldier(elite, level: 3, group: "Solo", extra_action: "")
    sheet(solo_later)

    assert_select "body", text: /additional standard action/i
  end

  test "a built monster moved to another rule set hides its builder summary" do
    built = entitybuilder_entities(:four_e_creature_built)
    sheet(built)

    assert_select "body", text: /Level 5 Soldier/

    built.update_columns(core_rules: "pf2e")
    sheet(built)

    assert_select "p", text: /Level 5 Soldier/, count: 0
  end

  test "elite cannot pick a third defense" do
    creature = entitybuilder_entities(:four_e_creature_unbuilt)

    build_soldier(creature, level: 3, group: "Elite", picks: %w[Fortitude Reflex Will])

    assert_response :unprocessable_content
    assert_select ".error"
    assert_nil Entitybuilder::Entity.find(creature.id).monster_level
    assert_nil defense_bonus(Entitybuilder::Entity.find(creature.id), "Armor Class")
  end

  test "level 3 solo brute shows armor class 17" do
    creature = build_soldier(level: 3, role: "Brute", group: "Solo")

    sheet(creature)

    assert_select ".sheet-over-big", text: "17"
  end

  test "level 3 standard brute shows armor class 15 and 56 hit points" do
    creature = build_soldier(level: 3, role: "Brute")

    sheet(creature)

    assert_select ".sheet-over-big", text: "15"
    assert_equal [ 56, 56 ], hit_points(creature)
  end

  test "level 3 elite lurker shows 78 hit points" do
    creature = build_soldier(level: 3, role: "Lurker", group: "Elite")

    assert_equal [ 78, 78 ], hit_points(creature)
  end

  test "level 2 solo controller shows 160 hit points" do
    creature = build_soldier(level: 2, role: "Controller", group: "Solo")

    assert_equal [ 160, 160 ], hit_points(creature)
  end

  test "minion shows 1 hit point" do
    creature = build_soldier(group: "Minion")

    assert_equal [ 1, 1 ], hit_points(creature)
  end

  test "edited armor class survives a level change and needs manual revision" do
    creature = build_soldier
    build(creature, level: 5, role: "Soldier", group: "Standard", values: { armor_class: "23" })

    creature = build_soldier(creature, level: 6)

    sheet(creature)

    assert_select ".sheet-over-big", text: "23"
    assert_select "tr.roll", text: /Fortitude\s+18/
    get "#{builder_path(creature)}/edit"

    assert_select "tr", text: /Armor Class.*needs manual revision/im
    assert_select "tr", text: /Fortitude.*needs manual revision/im, count: 0
  end

  test "reset restores the calculated armor class and clears the mark" do
    creature = build_soldier
    build(creature, level: 5, role: "Soldier", group: "Standard", values: { armor_class: "23" })

    delete "#{builder_path(creature)}/overrides/armor_class"

    assert_redirected_to "#{builder_path(creature)}/edit"
    follow_redirect!

    assert_select "tr", text: /needs manual revision/i, count: 0
    sheet(creature)

    assert_select ".sheet-over-big", text: "21"
  end

  test "existing 4e creature keeps its numbers until it opts in" do
    creature = entitybuilder_entities(:four_e_creature_designed)

    sheet(creature)

    assert_select ".sheet-over-big", text: "19"
    assert_nil creature.monster_level
    assert_equal [ 40, 40 ], hit_points(creature)
  end

  test "existing 4e creature keeps its designed numbers after opting in" do
    creature = build_soldier(entitybuilder_entities(:four_e_creature_designed))

    sheet(creature)

    assert_select ".sheet-over-big", text: "19"
    assert_equal [ 40, 40 ], hit_points(creature)
    assert_select "tr.roll", text: /Fortitude\s+17/
    get "#{builder_path(creature)}/edit"

    assert_select "tr", text: /Armor Class.*needs manual revision/im
    assert_select "tr", text: /Hit Points.*needs manual revision/im
  end
end
