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
end
