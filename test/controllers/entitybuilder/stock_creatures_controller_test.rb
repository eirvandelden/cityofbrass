# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class StockCreaturesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)
      @admin = admins(:dan)

      @creature = entitybuilder_entities(:stock_creature_one)
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
      sign_in @user
      get :new
      assert_response 403
    end

    test "should get new" do
      sign_in @user
      sign_in @admin
      get :new
      assert_response :success
    end

    test "should not create creature login" do
      assert_difference('Entity.count', 0) do
        post :create, params: { stock_creature: { name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
      end
      assert_response 302
    end

    test "should not create creature" do
      sign_in @user
      assert_difference('Entity.count', 0) do
        post :create, params: { stock_creature: { name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
      end
      assert_response 403
    end

    test "should create creature" do
      sign_in @user
      sign_in @admin
      assert_difference('Entity.count') do
        post :create, params: { stock_creature: { name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
      end
      assert_redirected_to edit_stock_creature_path(assigns(:entity))
    end

    test "should not show creature" do
      get :show, params: { id: @creature }
      assert_response 302
    end

    test "should show creature" do
      sign_in @user
      get :show, params: { id: @creature }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user
      get :edit, params: { id: @creature }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      sign_in @admin
      get :edit, params: { id: @creature }
      assert_response :success
    end

    test "should not update creature" do
      sign_in @user
      patch :update, params: { id: @creature, stock_creature: { name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
      assert_response 403
    end

    test "should update creature" do
      sign_in @user
      sign_in @admin
      patch :update, params: { id: @creature, stock_creature: { name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
      assert_redirected_to edit_stock_creature_path(assigns(:entity))
    end

    test "should not destroy creature" do
      sign_in @user
      assert_difference('Entity.count', 0) do
        delete :destroy, params: { id: @creature, stock_creature: { name: @creature.name } }
      end
      assert_response 403
    end

    test "should destroy creature" do
      sign_in @user
      sign_in @admin
      assert_difference('Entity.count', -1) do
        delete :destroy, params: { id: @creature, stock_creature: { name: @creature.name } }
      end
      assert_redirected_to stock_creatures_path
    end

  end
end
