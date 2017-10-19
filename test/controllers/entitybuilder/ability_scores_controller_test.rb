require 'test_helper'

module Entitybuilder
  class AbilityScoresControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @character = entitybuilder_entities(:resident_character_one)
      @ability_score = entitybuilder_ability_scores(:one)
    end

    test "should not get index" do
      get :index, params: { resident_character_id: @character.id }
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index, params: { resident_character_id: @character.id }
      assert_response :success
      assert_not_nil assigns(:ability_scores)
    end

    test "should not get new" do
      get :new, xhr: true, format: :js, params: { resident_character_id: @character.id }
      assert_response 401
    end

    test "should get new" do
      sign_in @user
      get :new, xhr: true, format: :js, params: { resident_character_id: @character.id }
      assert_response :success
    end

    test "should not create ability_score" do
      assert_difference('AbilityScore.count', 0) do
        post :create, format: :js, params: { ability_score: { name: 'NewName' }, resident_character_id: @character.id }
      end
      assert_response 401
    end

    test "should create ability_score 1" do
      sign_in @user
      assert_difference('AbilityScore.count') do
        post :create, format: :js, params: { ability_score: { sort_order: 0, name: 'NewName1' }, resident_character_id: @character.id }
      end
      assert_response :success
    end

    test "should create ability_score 2" do
      sign_in @user
      assert_difference('AbilityScore.count') do
        post :create, format: :js, params: { ability_score: { sort_order: 1, name: 'NewName2', description: 'NewDescription', base: 10, score: 12, modifier: 2, dice: '1d6' }, resident_character_id: @character.id }
      end
      assert_response :success
    end

    test "should not show ability_score" do
      get :show, xhr: true, format: :js, params: { id: @ability_score, resident_character_id: @character.id }
      assert_response 401
    end

    test "should show ability_score" do
      sign_in @user
      get :show, xhr: true, format: :js, params: { id: @ability_score, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, xhr: true, format: :js, params: { id: @ability_score, resident_character_id: @character.id }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, xhr: true, format: :js, params: { id: @ability_score, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not update ability_score" do
      sign_in @user2
      patch :update, xhr: true, format: :js, params: { id: @ability_score, ability_score: { name: @ability_score.name }, resident_character_id: @character.id }
      assert_response 403
    end

    test "should update ability_score" do
      sign_in @user
      patch :update, xhr: true, format: :js, params: { id: @ability_score, ability_score: { name: @ability_score.name }, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not destroy ability_score" do
      sign_in @user2
      assert_difference('AbilityScore.count', 0) do
        delete :destroy, format: :js, params: { id: @ability_score, resident_character_id: @character.id }
      end
      assert_response 403
    end

    test "should destroy ability_score" do
      sign_in @user
      assert_difference('AbilityScore.count', -1) do
        delete :destroy, format: :js, params: { id: @ability_score, resident_character_id: @character.id }
      end
      assert_response :success
    end

  end
end
