require "test_helper"

module Entitybuilder
  class SkillGroupingViewTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    tests Entitybuilder::ResidentCharactersController

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @character = entitybuilder_entities(:resident_character_one)
    end

    teardown do
      @character.skills.destroy_all
    end

    test "sheet renders skill group headings when skill_group is populated" do
      @character.skills.destroy_all
      @character.skills.create!(name: "Athletics", ability_score: "Might",  skill_group: "Exploration", sort_order: 0)
      @character.skills.create!(name: "Alchemy",   ability_score: "Reason", skill_group: "Crafting",    sort_order: 1)

      sign_in @user
      get :sheet, params: { resident_character_id: @character }

      assert_response :success
      assert_match(/Crafting/,    response.body)
      assert_match(/Exploration/, response.body)
      assert_match(/skill-group/, response.body)
    end

    test "sheet renders skills flat when skill_group is NULL on all skills" do
      @character.skills.destroy_all
      @character.skills.create!(name: "Athletics", ability_score: "Strength",  sort_order: 0)
      @character.skills.create!(name: "Stealth",   ability_score: "Dexterity", sort_order: 1)

      sign_in @user
      get :sheet, params: { resident_character_id: @character }

      assert_response :success
      assert_match(/Athletics/, response.body)
      assert_no_match(/skill-group/, response.body)
    end
  end
end
