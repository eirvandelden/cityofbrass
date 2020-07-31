# frozen_string_literal: false

require 'test_helper'

module Rulebuilder
  class ResidentRulesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Rulebuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @rule = rulebuilder_rules(:resident_one)
    end

    test "should not get index" do
      get :index
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index
      assert_response :success
      assert_not_nil assigns(:rules)
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

    test "should not create rule" do
      assert_difference('Rule.count', 0) do
        post :create, params: { resident_rule: { rule_type: @rule.rule_type, is_shared: @rule.is_shared, benefit: @rule.benefit, core_rules: @rule.core_rules, full_description: @rule.full_description, name: @rule.name, normal: @rule.normal, prerequisites: @rule.prerequisites, short_description: @rule.short_description, special: @rule.special, type: @rule.type, publisher: @rule.publisher, is_3pp: @rule.is_3pp, source: @rule.source, tags: @rule.tags } }
      end
      assert_response 302
    end

    test "should create rule" do
      sign_in @user
      assert_difference('Rule.count') do
        post :create, params: { resident_rule: { rule_type: @rule.rule_type, is_shared: @rule.is_shared, benefit: @rule.benefit, core_rules: @rule.core_rules, full_description: @rule.full_description, name: @rule.name, normal: @rule.normal, prerequisites: @rule.prerequisites, short_description: @rule.short_description, special: @rule.special, type: @rule.type, publisher: @rule.publisher, is_3pp: @rule.is_3pp, source: @rule.source, tags: @rule.tags } }
      end
      assert_redirected_to edit_resident_rule_path(assigns(:rule))
    end

    test "should not show rule" do
      get :show, params: { id: @rule }
      assert_response 302
    end

    test "should show rule" do
      sign_in @user
      get :show, params: { id: @rule }
      assert_response :success
    end

    test "should not show.js rule" do
      get :show, xhr: true, format: :js, params: { id: @rule }
      assert_response 401
    end

    test "should show.js rule" do
      sign_in @user
      get :show, xhr: true, format: :js, params: { id: @rule }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, params: { id: @rule }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, params: { id: @rule }
      assert_response :success
    end

    test "should not update rule" do
      sign_in @user2
      patch :update, params: { id: @rule, resident_rule: { rule_type: @rule.rule_type, is_shared: @rule.is_shared, benefit: @rule.benefit, core_rules: @rule.core_rules, full_description: @rule.full_description, name: @rule.name, normal: @rule.normal, prerequisites: @rule.prerequisites, short_description: @rule.short_description, special: @rule.special, type: @rule.type, publisher: @rule.publisher, is_3pp: @rule.is_3pp, source: @rule.source, tags: @rule.tags } }
      assert_response 403
    end

    test "should update rule" do
      sign_in @user
      patch :update, params: { id: @rule, resident_rule: { rule_type: @rule.rule_type, is_shared: @rule.is_shared, benefit: @rule.benefit, core_rules: @rule.core_rules, full_description: @rule.full_description, name: @rule.name, normal: @rule.normal, prerequisites: @rule.prerequisites, short_description: @rule.short_description, special: @rule.special, type: @rule.type, publisher: @rule.publisher, is_3pp: @rule.is_3pp, source: @rule.source, tags: @rule.tags } }
      assert_redirected_to edit_resident_rule_path(assigns(:rule))
    end

    test "should not update.js rule" do
      sign_in @user2
      patch :update, format: :js, params: { id: @rule, resident_rule: { rule_type: @rule.rule_type, is_shared: @rule.is_shared, benefit: @rule.benefit, core_rules: @rule.core_rules, full_description: @rule.full_description, name: @rule.name, normal: @rule.normal, prerequisites: @rule.prerequisites, short_description: @rule.short_description, special: @rule.special, type: @rule.type, publisher: @rule.publisher, is_3pp: @rule.is_3pp, source: @rule.source, tags: @rule.tags } }
      assert_response 403
    end

    test "should update.js rule" do
      sign_in @user
      patch :update, format: :js, params: { id: @rule, resident_rule: { rule_type: @rule.rule_type, is_shared: @rule.is_shared, benefit: @rule.benefit, core_rules: @rule.core_rules, full_description: @rule.full_description, name: @rule.name, normal: @rule.normal, prerequisites: @rule.prerequisites, short_description: @rule.short_description, special: @rule.special, type: @rule.type, publisher: @rule.publisher, is_3pp: @rule.is_3pp, source: @rule.source, tags: @rule.tags } }
      assert_response :success
    end

    test "should not destroy rule" do
      sign_in @user2
      assert_difference('Rule.count', 0) do
        delete :destroy, params: { id: @rule, resident_rule: { name: @rule.name } }
      end
      assert_response 403
    end

    test "should destroy rule" do
      sign_in @user
      assert_difference('Rule.count', -1) do
        delete :destroy, params: { id: @rule, resident_rule: { name: @rule.name } }
      end
      assert_redirected_to resident_rules_path
    end
  end
end
