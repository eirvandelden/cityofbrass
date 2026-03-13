require 'test_helper'

module Entitybuilder
  class KnownAbilitiesControllerTest < ActionController::TestCase
    setup do
      @known_ability = known_abilities(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:known_abilities)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create known_ability" do
      assert_difference('KnownAbility.count') do
        post :create, known_ability: { ability_id: @known_ability.ability_id, known_abilityable_id: @known_ability.known_abilityable_id, known_abilityable_type: @known_ability.known_abilityable_type, sort_order: @known_ability.sort_order }
      end

      assert_redirected_to known_ability_path(assigns(:known_ability))
    end

    test "should show known_ability" do
      get :show, id: @known_ability
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @known_ability
      assert_response :success
    end

    test "should update known_ability" do
      patch :update, id: @known_ability, known_ability: { ability_id: @known_ability.ability_id, known_abilityable_id: @known_ability.known_abilityable_id, known_abilityable_type: @known_ability.known_abilityable_type, sort_order: @known_ability.sort_order }
      assert_redirected_to known_ability_path(assigns(:known_ability))
    end

    test "should destroy known_ability" do
      assert_difference('KnownAbility.count', -1) do
        delete :destroy, id: @known_ability
      end

      assert_redirected_to known_abilities_path
    end
  end
end
