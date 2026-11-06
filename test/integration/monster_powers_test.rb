require "test_helper"

class MonsterPowersTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:dan)
  end

  def attacks_path(creature)
    "/eb/resident/creatures/#{creature.id}/attacks"
  end

  def add_power(creature, **fields)
    post attacks_path(creature), params: { attack: { name: "New power", attack_type: "Melee",
                                                     power_usage: "Encounter" }.merge(fields) }, xhr: true
  end

  def sheet(creature)
    get "/eb/resident/creatures/#{creature.id}/sheet"

    assert_response :success
  end

  test "elite power that recharges when first bloodied shows another use on the sheet" do
    sheet(entitybuilder_entities(:four_e_elite_level_3))

    assert_select "small.power-details", text: /Gains another use when first bloodied/
  end

  test "elite refuses a second power that recharges when first bloodied" do
    elite = entitybuilder_entities(:four_e_elite_level_3)

    assert_no_difference -> { elite.attacks.count } do
      add_power(elite, recharges_when_bloodied: "1")
    end
  end

  test "standard monster refuses recharges when first bloodied" do
    standard = entitybuilder_entities(:four_e_standard_level_3)

    assert_no_difference -> { standard.attacks.count } do
      add_power(standard, recharges_when_bloodied: "1")
    end
  end

  test "solo refuses a second power usable at will" do
    solo = entitybuilder_entities(:four_e_solo_level_3)

    assert_no_difference -> { solo.attacks.count } do
      add_power(solo, usable_at_will: "1")
    end
  end

  test "sheet shows an immediate interrupt action type" do
    standard = entitybuilder_entities(:four_e_standard_level_3)
    add_power(standard, action_type: "Immediate interrupt")

    assert_equal 1, standard.attacks.where(action_type: "Immediate interrupt").count
    sheet(standard)

    assert_select "small.power-details", text: /Immediate interrupt/
  end

  test "built monster saves an attack whose usage the form leaves blank" do
    standard = entitybuilder_entities(:four_e_standard_level_3)

    assert_difference -> { standard.attacks.count }, 1 do
      add_power(standard, power_usage: "")
    end
    assert_nil standard.attacks.find_by(name: "New power").power_usage
  end

  test "built monster edits an existing attack with the blank usage the form sends" do
    attack = entitybuilder_attacks(:elite_plain_power)
    attack.update_columns(power_usage: nil)

    put "/eb/resident/creatures/#{attack.entity_id}/attacks/#{attack.id}",
        params: { attack: { name: "Renamed", power_usage: "" } }, xhr: true

    assert_equal "Renamed", attack.reload.name
  end

  test "gm clears a stored mark after the group no longer allows it" do
    elite = entitybuilder_entities(:four_e_elite_level_3)
    marked = entitybuilder_attacks(:elite_marked_power)
    elite.update!(monster_group: "Standard")

    get "#{attacks_path(elite)}/#{marked.id}/edit", xhr: true

    assert_match "attack_recharges_when_bloodied", response.body
    put "#{attacks_path(elite)}/#{marked.id}",
        params: { attack: { power_usage: "At-will", recharges_when_bloodied: "0" } }, xhr: true

    assert_equal "At-will", marked.reload.power_usage
    assert_not marked.recharges_when_bloodied?
  end

  test "standard monster form offers no mark checkbox when none is stored" do
    standard = entitybuilder_entities(:four_e_standard_level_3)
    attack = standard.attacks.create!(name: "Plain", attack_type: "Melee")

    get "#{attacks_path(standard)}/#{attack.id}/edit", xhr: true

    assert_no_match "attack_recharges_when_bloodied", response.body
  end
end
