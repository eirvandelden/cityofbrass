require "test_helper"

module Entitybuilder
  class FifthEditionAttributionTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    tests Entitybuilder::ResidentCharactersController

    ATTRIBUTION = "System Reference Document 5.2.1"
    COPYRIGHT = "Wizards of the Coast LLC"

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @character = entitybuilder_entities(:fifth_edition_character)
    end

    test "sheet view renders 5th Edition attribution" do
      sign_in @user
      get :sheet, params: { resident_character_id: @character }

      assert_response :success
      assert_match(/#{Regexp.escape(ATTRIBUTION)}/i, response.body)
      assert_match(/#{Regexp.escape(COPYRIGHT)}/, response.body)
    end

    test "card view renders 5th Edition attribution" do
      sign_in @user
      get :card, params: { resident_character_id: @character }

      assert_response :success
      assert_match(/#{Regexp.escape(ATTRIBUTION)}/i, response.body)
    end

    test "edit form renders 5th Edition attribution" do
      sign_in @user
      get :edit, params: { id: @character }

      assert_response :success
      assert_match(/#{Regexp.escape(ATTRIBUTION)}/i, response.body)
      assert_match(/#{Regexp.escape(COPYRIGHT)}/, response.body)
    end
  end
end
