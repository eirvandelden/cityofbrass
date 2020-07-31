# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class LinkedRulesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @character = entitybuilder_entities(:resident_character_one)
      @linked_rule = entitybuilder_linked_rules(:one)
    end

    test "should not get index" do
      get :index, params: { resident_character_id: @character.id }
      assert_response 302
    end

    test "should not get index with invalid rule" do
      sign_in @user
      get :index, params: { resident_character_id: @character.id, rule_type: 'stunt' }
      assert_response 404
    end

    test "should get index" do
      sign_in @user
      get :index, params: { resident_character_id: @character.id, rule_type: 'feat' }
      assert_response :success
      assert_not_nil assigns(:linked_rules)
    end

    test "should not get new" do
      get :new, xhr: true, format: :js, params: { resident_character_id: @character.id }
      assert_response 401
    end

    test "should not get new with invalid rule" do
      sign_in @user
      get :new, xhr: true, format: :js, params: { resident_character_id: @character.id, type: 'new', rule_type: 'stunt' }
      assert_response 404
    end

    test "should get new" do
      sign_in @user
      get :new, xhr: true, format: :js, params: { resident_character_id: @character.id, type: 'new', rule_type: 'feat' }
      assert_response :success
    end

    test "should not create linked_rule" do
      assert_difference('LinkedRule.count', 0) do
        post :create, format: :js, params: { linked_rule: { name: 'NewName' }, resident_character_id: @character.id }
      end
      assert_response 401
    end

    test "should create linked_rule 1" do
      sign_in @user
      assert_difference('LinkedRule.count') do
        post :create, format: :js, params: { linked_rule: { sort_order: 0, rule_id: @linked_rule.rule.id }, resident_character_id: @character.id }
      end
      assert_response :success
    end

    test "should create linked_rule 2" do
      sign_in @user
      assert_difference('LinkedRule.count') do
        post :create, format: :js, params: { linked_rule: { sort_order: 1, rule_id: @linked_rule.rule.id, detail: 'NewDescription' }, resident_character_id: @character.id }
      end
      assert_response :success
    end

    test "should not show linked_rule" do
      get :show, xhr: true, format: :js, params: { id: @linked_rule, resident_character_id: @character.id }
      assert_response 401
    end

    test "should show linked_rule" do
      sign_in @user
      get :show, xhr: true, format: :js, params: { id: @linked_rule, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, xhr: true, format: :js, params: { id: @linked_rule, resident_character_id: @character.id }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, xhr: true, format: :js, params: { id: @linked_rule, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not update linked_rule" do
      sign_in @user2
      patch :update, xhr: true, format: :js, params: { id: @linked_rule, linked_rule: { rule_id: @linked_rule.rule.id }, resident_character_id: @character.id }
      assert_response 403
    end

    test "should update linked_rule" do
      sign_in @user
      patch :update, xhr: true, format: :js, params: { id: @linked_rule, linked_rule: { rule_id: @linked_rule.rule.id }, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not destroy linked_rule" do
      sign_in @user2
      assert_difference('LinkedRule.count', 0) do
        delete :destroy, format: :js, params: { id: @linked_rule, resident_character_id: @character.id }
      end
      assert_response 403
    end

    test "should destroy linked_rule" do
      sign_in @user
      assert_difference('LinkedRule.count', -1) do
        delete :destroy, format: :js, params: { id: @linked_rule, resident_character_id: @character.id }
      end
      assert_response :success
    end

  end
end
