# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class LinkedRulesControllerTest < ActionController::TestCase
    setup do
      @linked_rule = entitybuilder_linked_rules(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:linked_rules)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create linked_rule" do
      assert_difference('LinkedRule.count') do
        post :create, linked_rule: { detail: @linked_rule.detail, linked_rule_id: @linked_rule.linked_rule_id, linked_rule_type: @linked_rule.linked_rule_type, rule_id: @linked_rule.rule_id, sort_order: @linked_rule.sort_order }
      end

      assert_redirected_to linked_rule_path(assigns(:linked_rule))
    end

    test "should show linked_rule" do
      get :show, id: @linked_rule
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @linked_rule
      assert_response :success
    end

    test "should update linked_rule" do
      patch :update, id: @linked_rule, linked_rule: { detail: @linked_rule.detail, linked_rule_id: @linked_rule.linked_rule_id, linked_rule_type: @linked_rule.linked_rule_type, rule_id: @linked_rule.rule_id, sort_order: @linked_rule.sort_order }
      assert_redirected_to linked_rule_path(assigns(:linked_rule))
    end

    test "should destroy linked_rule" do
      assert_difference('LinkedRule.count', -1) do
        delete :destroy, id: @linked_rule
      end

      assert_redirected_to linked_rules_path
    end
  end
end
