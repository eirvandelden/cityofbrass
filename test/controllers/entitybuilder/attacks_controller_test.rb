require 'test_helper'

module Entitybuilder
  class AttacksControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @character = entitybuilder_entities(:resident_character_one)
      @attack = entitybuilder_attacks(:one)
    end

    test "should not get index" do
      get :index, params: { resident_character_id: @character.id }
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index, params: { resident_character_id: @character.id }
      assert_response :success
      assert_not_nil assigns(:attacks)
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

    test "should not create attack" do
      assert_difference('Attack.count', 0) do
        post :create, format: :js, params: { attack: { name: 'NewName' }, resident_character_id: @character.id }
      end
      assert_response 401
    end

    test "should create attack 1" do
      sign_in @user
      assert_difference('Attack.count') do
        post :create, format: :js, params: { attack: { sort_order: 0, name: 'NewName1', attack_type: 'Melee' }, resident_character_id: @character.id }
      end
      assert_response :success
    end

    test "should create attack 2" do
      sign_in @user
      assert_difference('Attack.count') do
        post :create, format: :js, params: { attack: { sort_order: 1, name: 'NewName2', attack_type: 'Range' }, resident_character_id: @character.id }
      end
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, xhr: true, format: :js, params: { id: @attack, resident_character_id: @character.id }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, xhr: true, format: :js, params: { id: @attack, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not update attack" do
      sign_in @user2
      patch :update, xhr: true, format: :js, params: { id: @attack, attack: { name: @attack.name }, resident_character_id: @character.id }
      assert_response 403
    end

    test "should update attack" do
      sign_in @user
      patch :update, xhr: true, format: :js, params: { id: @attack, attack: { name: @attack.name }, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not destroy attack" do
      sign_in @user2
      assert_difference('Attack.count', 0) do
        delete :destroy, format: :js, params: { id: @attack, resident_character_id: @character.id }
      end
      assert_response 403
    end

    test "should destroy attack" do
      sign_in @user
      assert_difference('Attack.count', -1) do
        delete :destroy, format: :js, params: { id: @attack, resident_character_id: @character.id }
      end
      assert_response :success
    end

  end
end
