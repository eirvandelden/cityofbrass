require "test_helper"

class CampaignSectionFormTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { @game_master = users(:dan) }

  # Regression for POST /cm/campaigns/:id/sections/:uuid 404 — the new-section
  # form had the section UUID baked into the action URL.
  test "section can be created under a newly created campaign" do
    sign_in @game_master

    post "/cm/campaigns", params: { campaign: {
      name: "Section Regression", privacy: "Private", core_rules: "pf1e",
      short_description: "x", full_description: "<p>x</p>"
    } }
    campaign = Campaignmanager::Campaign.find_by!(name: "Section Regression")

    get "/cm/campaigns/#{campaign.id}/sections/new/text", xhr: true
    assert_response :success

    # new_section_type.js.erb wraps the partial in `j render("form")`, so the
    # response body contains JS-escaped form HTML — match either escaped or raw.
    action = response.body[/<form[^>]*action=(?:"|\\")([^"\\]+)/, 1]
    assert action, "no <form action=...> in response body"
    assert_match %r{\A/cm/campaigns/#{campaign.id}/sections/?\z}, action,
                 "new-section form must post to the sections collection, got #{action.inspect}"

    assert_difference "Campaignmanager::Section.count", 1 do
      post action, xhr: true, params: { section: {
        section_type: "text", section_style: "default",
        header: "Regression", content: "<p>Regression body</p>", sort_order: 0
      } }
    end
    assert_response :success
  end

  test "campaign page content forms post to nested collections" do
    sign_in @game_master

    campaign = campaignmanager_campaigns(:resident_one)
    page = campaignmanager_pages(:adventure_log_one)

    assert_form_action "/cm/campaigns/#{campaign.id}/adventure_logs/#{page.id}/features/new/text",
                       "/cm/campaigns/#{campaign.id}/adventure_logs/#{page.id}/features"
    assert_form_action "/cm/campaigns/#{campaign.id}/adventure_logs/#{page.id}/sections/new/text",
                       "/cm/campaigns/#{campaign.id}/adventure_logs/#{page.id}/sections"
    assert_form_action "/cm/campaigns/#{campaign.id}/adventure_logs/#{page.id}/notables/new?entity_type=resident_npc",
                       "/cm/campaigns/#{campaign.id}/adventure_logs/#{page.id}/notables"
  end

  test "story page content forms post to nested collections" do
    sign_in @game_master

    adventure = storybuilder_adventures(:resident_one)
    page = storybuilder_pages(:page_one)

    assert_form_action "/sb/resident/adventures/#{adventure.id}/pages/#{page.id}/features/new?feature_type=text",
                       "/sb/resident/adventures/#{adventure.id}/pages/#{page.id}/features"
    assert_form_action "/sb/resident/adventures/#{adventure.id}/pages/#{page.id}/sections/new?section_type=text",
                       "/sb/resident/adventures/#{adventure.id}/pages/#{page.id}/sections"
    assert_form_action "/sb/resident/adventures/#{adventure.id}/pages/#{page.id}/notables/new?entity_type=resident_npc",
                       "/sb/resident/adventures/#{adventure.id}/pages/#{page.id}/notables"
  end

  test "world page content forms post to nested collections" do
    sign_in @game_master

    district = worldbuilder_districts(:district_one)
    page = worldbuilder_pages(:page_one)

    assert_form_action "/wb/#{district.slug}/pages/#{page.id}/features/new?feature_type=text",
                       "/wb/#{district.slug}/pages/#{page.id}/features"
    assert_form_action "/wb/#{district.slug}/pages/#{page.id}/sections/new?section_type=text",
                       "/wb/#{district.slug}/pages/#{page.id}/sections"
  end

  private

    def assert_form_action(path, expected_action)
      get path, xhr: true
      assert_response :success

      action = response.body[/<form[^>]*action=(?:"|\\")([^"\\]+)/, 1]
      assert_equal expected_action, action
    end
end
