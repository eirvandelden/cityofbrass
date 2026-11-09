require "test_helper"

class MonsterDifficultyTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:dan)
  end

  def builder(creature)
    get "/eb/resident/creatures/#{creature.id}/monster_build/edit"

    assert_response :success
  end

  def assert_rating(fixture, rating)
    builder(entitybuilder_entities(fixture))

    assert_select "p.encounter-difficulty-rating[data-rating=?]", rating
  end

  test "level 5 standard monster against five level 5 characters is easy" do
    assert_rating(:four_e_difficulty_standard_5, "easy")
    assert_select "p.encounter-difficulty-party", text: /5 characters.*level 5/
  end

  test "level 5 solo against five level 5 characters is standard" do
    assert_rating(:four_e_difficulty_solo_5, "standard")
  end

  test "level 3 minion against four level 3 characters is easy" do
    assert_rating(:four_e_difficulty_minion_3, "easy")
  end

  test "level 9 solo against five level 5 characters is hard" do
    assert_rating(:four_e_difficulty_solo_9, "hard")
  end

  test "level 10 solo against five level 5 characters is impossible" do
    assert_rating(:four_e_difficulty_solo_10, "impossible")
  end

  test "campaign without characters shows a hint instead of a difficulty" do
    builder(entitybuilder_entities(:four_e_difficulty_empty_party))

    assert_select "p.encounter-difficulty-rating", count: 0
    assert_select "p.encounter-difficulty-hint"
  end

  test "picking a campaign through the form shows its difficulty" do
    creature = entitybuilder_entities(:four_e_creature_built)
    campaign = campaignmanager_campaigns(:dnd4e_party_of_five)

    patch "/eb/resident/creatures/#{creature.id}/monster_build",
          params: { resident_creature: { monster_level: 5, monster_role: "Soldier", monster_group: "Standard",
                                         encounter_campaign_id: campaign.id } }

    assert_redirected_to "/eb/resident/creatures/#{creature.id}/monster_build/edit"
    assert_equal campaign.id, creature.reload.encounter_campaign_id
  end

  test "a blank campaign choice clears the campaign" do
    creature = entitybuilder_entities(:four_e_difficulty_standard_5)

    patch "/eb/resident/creatures/#{creature.id}/monster_build",
          params: { resident_creature: { monster_level: 5, monster_role: "Soldier", monster_group: "Standard",
                                         encounter_campaign_id: "" } }

    assert_nil creature.reload.encounter_campaign_id
  end

  test "pathfinder 2e creature has no builder, difficulty or power fields" do
    creature = entitybuilder_entities(:resident_creature_pf2e)
    get "/eb/resident/creatures/#{creature.id}/monster_build/edit"

    assert_response :not_found
    assert_nil creature.reload.encounter_campaign_id
  end
end
