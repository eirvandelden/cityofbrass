require "test_helper"

module Entitybuilder
  # Tests that the ORC License attribution string appears on all three required
  # user-facing surfaces for Pathfinder 2e content.
  class Pf2eAttributionTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    tests Entitybuilder::ResidentCharactersController

    ATTRIBUTION_MATCH = /ORC/i
    COPYRIGHT_MATCH   = /Paizo/i

    setup do
      @routes    = Entitybuilder::Engine.routes
      @user      = users(:dan)
      @character = entitybuilder_entities(:pf2e_character)
    end

    # Surface 1: Sheet view
    test "sheet view renders ORC License attribution" do
      sign_in @user
      get :sheet, params: { resident_character_id: @character }
      assert_response :success
      assert_match(ATTRIBUTION_MATCH, response.body)
      assert_match(COPYRIGHT_MATCH, response.body)
    end

    # Surface 2: Card view (export / print equivalent)
    test "card view renders ORC License attribution" do
      sign_in @user
      get :card, params: { resident_character_id: @character }
      assert_response :success
      assert_match(ATTRIBUTION_MATCH, response.body)
    end

    # Surface 3: Edit form — renders the attribution alongside the system field
    # once a system is bound to the entity.
    test "edit form renders ORC License attribution" do
      sign_in @user
      get :edit, params: { id: @character }
      assert_response :success
      assert_match(ATTRIBUTION_MATCH, response.body)
      assert_match(COPYRIGHT_MATCH, response.body)
    end
  end
end
