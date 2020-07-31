# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class ResidentCreaturesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @creature = entitybuilder_entities(:resident_creature_one)
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

    test "should not create creature" do
      assert_difference('Entity.count', 0) do
        post :create, params: { resident_creature: { resident_id: @creature.resident_id, name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
      end
      assert_response 302
    end

    test "should create creature" do
      sign_in @user
      assert_difference('Entity.count') do
        post :create, params: { resident_creature: { resident_id: @creature.resident_id, name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
      end
      assert_redirected_to edit_resident_creature_path(assigns(:entity))
    end

    test "should not create third creature for free user" do
      sign_in @user2
      assert_difference('Entity.count', 0) do
        post :create, params: { resident_creature: { resident_id: @creature.resident_id, name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
      end
      assert_redirected_to "/billing/subscriptions"
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

    test "should show creature sheet" do
      sign_in @user
      get :sheet, params: { resident_creature_id: @creature }
      assert_response :success
    end

    test "should show creature profile" do
      sign_in @user
      get :sheet, params: { resident_creature_id: @creature }
      assert_response :success
    end

    test "should show creature card" do
      sign_in @user
      get :sheet, params: { resident_creature_id: @creature }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, params: { id: @creature }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, params: { id: @creature }
      assert_response :success
    end

    test "should not update creature" do
      sign_in @user2
      patch :update, params: { id: @creature, resident_creature: { resident_id: @creature.resident_id, name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
      assert_response 403
    end

    test "should update creature" do
      sign_in @user
      patch :update, params: { id: @creature, resident_creature: { resident_id: @creature.resident_id, name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
      assert_redirected_to edit_resident_creature_path(assigns(:entity))
    end

    test "should not update_notes.js creature" do
      sign_in @user2
      patch :update_notes, format: :js, params: { resident_creature_id: @creature, resident_creature: { resident_id: @creature.resident_id, name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
      assert_response 403
    end

    test "should update_notes.js creature" do
      sign_in @user
      patch :update_notes, format: :js, params: { resident_creature_id: @creature, resident_creature: { resident_id: @creature.resident_id, name: @creature.name, privacy: @creature.privacy, sheet_privacy: @creature.sheet_privacy, core_rules: @creature.core_rules, short_description: @creature.short_description, full_description: @creature.full_description, notes: @creature.notes, type: @creature.type, publisher: @creature.publisher, is_3pp: @creature.is_3pp, source: @creature.source, tags: @creature.tags } }
      assert_response :success
    end

    test "should not destroy creature" do
      sign_in @user2
      assert_difference('Entity.count', 0) do
        delete :destroy, params: { id: @creature, resident_creature: { name: @creature.name } }
      end
      assert_response 403
    end

    test "should destroy creature" do
      sign_in @user
      assert_difference('Entity.count', -1) do
        delete :destroy, params: { id: @creature, resident_creature: { name: @creature.name } }
      end
      assert_redirected_to resident_creatures_path
    end

  end
end
