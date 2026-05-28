require "test_helper"

module Entitybuilder
  # Tests that the Draw Steel Creator License attribution string appears on all
  # three required user-facing surfaces per the Draw Steel Creator License.
  class DrawSteelAttributionTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    tests Entitybuilder::ResidentCharactersController

    ATTRIBUTION = "Draw Steel Creator License"
    COPYRIGHT   = "MCDM Productions"

    setup do
      @routes    = Entitybuilder::Engine.routes
      @user      = users(:dan)
      @character = entitybuilder_entities(:draw_steel_character)
    end

    # Surface 1: Sheet view
    test "sheet view renders Draw Steel Creator License attribution" do
      sign_in @user
      get :sheet, params: { resident_character_id: @character }
      assert_response :success
      assert_match(/#{Regexp.escape(ATTRIBUTION)}/i, response.body)
      assert_match(/#{Regexp.escape(COPYRIGHT)}/, response.body)
    end

    # Surface 2: Card view (export / print equivalent)
    test "card view renders Draw Steel Creator License attribution" do
      sign_in @user
      get :card, params: { resident_character_id: @character }
      assert_response :success
      assert_match(/#{Regexp.escape(ATTRIBUTION)}/i, response.body)
    end

    # Surface 3: System picker / settings — edit form for an entity with
    # Draw Steel selected renders the attribution alongside the system field.
    # (The new form's picker dropdown lists all systems by name; per-system
    # attribution renders once a system is bound to the entity.)
    test "edit form renders Draw Steel Creator License attribution" do
      sign_in @user
      get :edit, params: { id: @character }
      assert_response :success
      assert_match(/#{Regexp.escape(ATTRIBUTION)}/i, response.body)
      assert_match(/#{Regexp.escape(COPYRIGHT)}/, response.body)
    end
  end
end
