require 'test_helper'

module Rulebuilder
  class RulesControllerTest < ActionController::TestCase
    setup do
      @rule = rulebuilder_rules(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:rules)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create rule" do
      assert_difference('Rule.count') do
        post :create, rule: { benefit: @rule.benefit, core_rules: @rule.core_rules, full_description: @rule.full_description, is_3pp: @rule.is_3pp, name: @rule.name, normal: @rule.normal, parent_id: @rule.parent_id, prerequisites: @rule.prerequisites, publisher: @rule.publisher, resident_id: @rule.resident_id, rule_type: @rule.rule_type, short_description: @rule.short_description, source: @rule.source, special: @rule.special, tags: @rule.tags, type: @rule.type }
      end

      assert_redirected_to rule_path(assigns(:rule))
    end

    test "should show rule" do
      get :show, id: @rule
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @rule
      assert_response :success
    end

    test "should update rule" do
      patch :update, id: @rule, rule: { benefit: @rule.benefit, core_rules: @rule.core_rules, full_description: @rule.full_description, is_3pp: @rule.is_3pp, name: @rule.name, normal: @rule.normal, parent_id: @rule.parent_id, prerequisites: @rule.prerequisites, publisher: @rule.publisher, resident_id: @rule.resident_id, rule_type: @rule.rule_type, short_description: @rule.short_description, source: @rule.source, special: @rule.special, tags: @rule.tags, type: @rule.type }
      assert_redirected_to rule_path(assigns(:rule))
    end

    test "should destroy rule" do
      assert_difference('Rule.count', -1) do
        delete :destroy, id: @rule
      end

      assert_redirected_to rules_path
    end
  end
end
