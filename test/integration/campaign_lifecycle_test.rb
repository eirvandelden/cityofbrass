require "test_helper"

class CampaignLifecycleTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @game_master = users(:dan)
    @player = users(:lucas)
    @non_player = users(:brittany)
    @player_affiliation = affiliations(:affiliation1)
    @player_character = entitybuilder_entities(:resident_character_three)
  end

  test "game master creates a campaign" do
    sign_in @game_master

    assert_difference "Campaignmanager::Campaign.count", 1 do
      post "/cm/campaigns", params: { campaign: campaign_params(name: "Hollow Crown") }
    end

    campaign = Campaignmanager::Campaign.find_by!(name: "Hollow Crown")
    assert_equal residents(:razune), campaign.resident
    assert_redirected_to "/cm/campaigns/#{campaign.id}/edit"
  end

  test "game master adds an affiliated resident as campaign player" do
    sign_in @game_master
    campaign = create_campaign(name: "Broken Tower")

    assert_difference "Campaignmanager::Player.count", 1 do
      post "/cm/campaigns/#{campaign.id}/players",
           xhr: true,
           params: { player: { affiliation_id: @player_affiliation.id } }
    end

    campaign_player = campaign.players.find_by!(affiliation: @player_affiliation)
    assert_equal residents(:tuandn), campaign_player.affiliate
  end

  test "private campaign is visible to players but not other residents" do
    sign_in @game_master
    campaign = create_campaign(name: "Silent Gate", privacy: "Private")
    campaign.players.create!(affiliation: @player_affiliation)
    sign_out @game_master

    sign_in @non_player
    get "/cm/campaigns/#{campaign.id}"
    assert_response :forbidden
    sign_out @non_player

    sign_in @player
    get "/cm/campaigns/#{campaign.id}"
    assert_response :success

    get "/cm/campaigns/#{campaign.id}/edit"
    assert_response :forbidden
  end

  test "player joins one of their characters to a campaign" do
    sign_in @game_master
    campaign = create_campaign(name: "Glass Road", privacy: "Private")
    campaign.players.create!(affiliation: @player_affiliation)
    sign_out @game_master

    sign_in @player
    assert_difference "Entitybuilder::CampaignJoin.count", 1 do
      patch "/eb/resident/characters/#{@player_character.id}", params: {
        resident_character: {
          name: @player_character.name,
          privacy: @player_character.privacy,
          sheet_privacy: @player_character.sheet_privacy,
          short_description: @player_character.short_description,
          full_description: @player_character.full_description,
          campaign_join_attributes: { campaign_id: campaign.id }
        }
      }
    end

    assert_redirected_to "/eb/resident/characters/#{@player_character.id}/edit"

    get "/cm/campaigns/#{campaign.id}/characters"
    assert_response :success
    assert_includes response.body, @player_character.name
  end

  private

    def create_campaign(name:, privacy: "Private")
      post "/cm/campaigns", params: { campaign: campaign_params(name: name, privacy: privacy) }
      Campaignmanager::Campaign.find_by!(name: name)
    end

    def campaign_params(name:, privacy: "Private")
      {
        name: name,
        privacy: privacy,
        core_rules: "PFRPG",
        short_description: "A campaign for integration testing.",
        full_description: "<p>A campaign for integration testing.</p>"
      }
    end
end
