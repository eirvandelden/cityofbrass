require "application_system_test_case"

class MonsterPowerPrefillTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:dan), scope: :user

    assert_text "Signed in successfully."
  end

  def open_power_form(monster, name)
    visit "/eb/resident/creatures/#{monster.id}/attacks"
    find("a.cogs.add").click
    fill_in "attack_name", with: name
    select "Melee", from: "attack_attack_type"
  end

  def save_power(monster, name)
    click_button "Save"

    assert_text "#{name}"
    monster.attacks.find_by(name: name)
  end

  def assert_prefill(monster, name, attack_bonus:, damage_bonus:)
    assert_field "attack_attack_bonus", with: attack_bonus.to_s
    assert_field "attack_damage_bonus", with: damage_bonus.to_s
    power = save_power(monster, name)

    assert_equal attack_bonus, power.attack_bonus
    assert_equal damage_bonus, power.damage_bonus
  end

  test "at-will power of a level 4 brute prefills attack 9 and damage 15" do
    brute = entitybuilder_entities(:four_e_brute_level_4)
    open_power_form(brute, "Smash")
    select "At-will", from: "attack_power_usage"

    assert_prefill(brute, "Smash", attack_bonus: 9, damage_bonus: 15)
  end

  test "encounter power of a level 4 skirmisher prefills damage 15" do
    skirmisher = entitybuilder_entities(:four_e_skirmisher_level_4)
    open_power_form(skirmisher, "Stab")
    select "Encounter", from: "attack_power_usage"

    assert_prefill(skirmisher, "Stab", attack_bonus: 9, damage_bonus: 15)
  end

  test "at-will power of a level 4 minion prefills damage 6" do
    minion = entitybuilder_entities(:four_e_minion_level_4)
    open_power_form(minion, "Poke")
    select "At-will", from: "attack_power_usage"

    assert_prefill(minion, "Poke", attack_bonus: 9, damage_bonus: 6)
  end

  test "multi-target power of a level 4 skirmisher prefills damage 9" do
    skirmisher = entitybuilder_entities(:four_e_skirmisher_level_4)
    open_power_form(skirmisher, "Whirl")
    select "At-will", from: "attack_power_usage"
    check "attack_multi_target"

    assert_prefill(skirmisher, "Whirl", attack_bonus: 9, damage_bonus: 9)
  end

  test "solo encounter power usable at will prefills at-will damage" do
    solo = entitybuilder_entities(:four_e_solo_level_3_open)
    open_power_form(solo, "Roar")
    select "Encounter", from: "attack_power_usage"

    assert_field "attack_damage_bonus", with: "17"
    check "attack_usable_at_will"

    assert_prefill(solo, "Roar", attack_bonus: 8, damage_bonus: 13)
  end
end
