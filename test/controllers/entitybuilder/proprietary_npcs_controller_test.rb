# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class ProprietaryNpcsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)
      @admin = admins(:dan)

      @npc = entitybuilder_entities(:proprietary_npc_one)
    end

    test "should not get index" do
      get :index
      assert_response 302
    end

    test "should not get index for user" do
      sign_in @user
      get :index
      assert_response 403
    end

    test "should get index" do
      sign_in @user
      sign_in @admin
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

    test "should not create npc login" do
      assert_difference('Entity.count', 0) do
        post :create, params: { proprietary_npc: { name: @npc.name, privacy: @npc.privacy, sheet_privacy: @npc.sheet_privacy, core_rules: @npc.core_rules, short_description: @npc.short_description, full_description: @npc.full_description, notes: @npc.notes, type: @npc.type, publisher: @npc.publisher, is_3pp: @npc.is_3pp, source: @npc.source, tags: @npc.tags } }
      end
      assert_response 302
    end

    test "should not create npc" do
      sign_in @user
      assert_difference('Entity.count', 0) do
        post :create, params: { proprietary_npc: { name: @npc.name, privacy: @npc.privacy, sheet_privacy: @npc.sheet_privacy, core_rules: @npc.core_rules, short_description: @npc.short_description, full_description: @npc.full_description, notes: @npc.notes, type: @npc.type, publisher: @npc.publisher, is_3pp: @npc.is_3pp, source: @npc.source, tags: @npc.tags } }
      end
      assert_response 403
    end

    test "should create npc" do
      sign_in @user
      sign_in @admin
      assert_difference('Entity.count') do
        post :create, params: { proprietary_npc: { name: @npc.name, privacy: @npc.privacy, sheet_privacy: @npc.sheet_privacy, core_rules: @npc.core_rules, short_description: @npc.short_description, full_description: @npc.full_description, notes: @npc.notes, type: @npc.type, publisher: @npc.publisher, is_3pp: @npc.is_3pp, source: @npc.source, tags: @npc.tags } }
      end
      assert_redirected_to edit_proprietary_npc_path(assigns(:entity))
    end

    test "should not show npc" do
      get :show, params: { id: @npc }
      assert_response 302
    end

    test "should show npc" do
      sign_in @user
      get :show, params: { id: @npc }
      assert_response :success
    end

    test "should show npc mobile" do
      request.variant = :phone
      sign_in @user
      get :show, params: { id: @npc }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user
      get :edit, params: { id: @npc }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      sign_in @admin
      get :edit, params: { id: @npc }
      assert_response :success
    end

    test "should not update npc" do
      sign_in @user
      patch :update, params: { id: @npc, proprietary_npc: { name: @npc.name, privacy: @npc.privacy, sheet_privacy: @npc.sheet_privacy, core_rules: @npc.core_rules, short_description: @npc.short_description, full_description: @npc.full_description, notes: @npc.notes, type: @npc.type, publisher: @npc.publisher, is_3pp: @npc.is_3pp, source: @npc.source, tags: @npc.tags } }
      assert_response 403
    end

    test "should update npc" do
      sign_in @user
      sign_in @admin
      patch :update, params: { id: @npc, proprietary_npc: { name: @npc.name, privacy: @npc.privacy, sheet_privacy: @npc.sheet_privacy, core_rules: @npc.core_rules, short_description: @npc.short_description, full_description: @npc.full_description, notes: @npc.notes, type: @npc.type, publisher: @npc.publisher, is_3pp: @npc.is_3pp, source: @npc.source, tags: @npc.tags } }
      assert_redirected_to edit_proprietary_npc_path(assigns(:entity))
    end

    test "should not destroy npc" do
      sign_in @user
      assert_difference('Entity.count', 0) do
        delete :destroy, params: { id: @npc, proprietary_npc: { name: @npc.name } }
      end
      assert_response 403
    end

    test "should destroy npc" do
      sign_in @user
      sign_in @admin
      assert_difference('Entity.count', -1) do
        delete :destroy, params: { id: @npc, proprietary_npc: { name: @npc.name } }
      end
      assert_redirected_to proprietary_npcs_path
    end

  end
end
