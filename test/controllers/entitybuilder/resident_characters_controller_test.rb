# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class ResidentCharactersControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @character = entitybuilder_entities(:resident_character_one)
      @character2 = entitybuilder_entities(:resident_character_two)
    end

    test "should not get index" do
      get :index
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index
      assert_response :success
      assert_not_nil assigns(:entities)
    end

    test "should not get new" do
      get :new
      assert_response 302
    end

    test "should get new" do
      sign_in @user
      get :new
      assert_response :success
    end

    test "should not create character" do
      assert_difference('Entity.count', 0) do
        post :create, params: { resident_character: { resident_id: @character.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      end
      assert_response 302
    end

    test "should create character" do
      sign_in @user
      assert_difference('Entity.count') do
        post :create, params: { resident_character: { resident_id: @character.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      end
      assert_redirected_to edit_resident_character_path(assigns(:entity))
    end

    test "should not create third character for free user" do
      sign_in @user2
      assert_difference('Entity.count', 0) do
        post :create, params: { resident_character: { resident_id: @character2.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      end
      assert_redirected_to "/billing/subscriptions"
    end

    test "should not show character" do
      get :show, params: { id: @character }
      assert_response 302
    end

    test "should show character" do
      sign_in @user
      get :show, params: { id: @character }
      assert_response :success
    end

    test "should show character mobile" do
      request.variant = :phone
      sign_in @user
      get :show, params: { id: @character }
      assert_response :success
    end

    test "should show character sheet" do
      sign_in @user
      get :sheet, params: { resident_character_id: @character }
      assert_response :success
    end

    test "should show character profile" do
      sign_in @user
      get :sheet, params: { resident_character_id: @character }
      assert_response :success
    end

    test "should show character card" do
      sign_in @user
      get :sheet, params: { resident_character_id: @character }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, params: { id: @character }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, params: { id: @character }
      assert_response :success
    end

    test "should not update character" do
      sign_in @user2
      patch :update, params: { id: @character, resident_character: { resident_id: @character.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      assert_response 403
    end

    test "should update character" do
      sign_in @user
      patch :update, params: { id: @character, resident_character: { resident_id: @character.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      assert_redirected_to edit_resident_character_path(assigns(:entity))
    end

    test "should not update_notes.js character" do
      sign_in @user2
      patch :update_notes, format: :js, params: { resident_character_id: @character, resident_character: { resident_id: @character.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      assert_response 403
    end

    test "should update_notes.js character" do
      sign_in @user
      patch :update_notes, format: :js, params: { resident_character_id: @character, resident_character: { resident_id: @character.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      assert_response :success
    end

    test "should not destroy character" do
      sign_in @user2
      assert_difference('Entity.count', 0) do
        delete :destroy, params: { id: @character, resident_character: { name: @character.name } }
      end
      assert_response 403
    end

    test "should destroy character" do
      sign_in @user
      assert_difference('Entity.count', -1) do
        delete :destroy, params: { id: @character, resident_character: { name: @character.name } }
      end
      assert_redirected_to resident_characters_path
    end

  end
end
