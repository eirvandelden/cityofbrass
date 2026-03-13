require 'test_helper'

module Entitybuilder
  class EntitiesControllerTest < ActionController::TestCase
    setup do
      @entity = entities(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:entities)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create entity" do
      assert_difference('Entity.count') do
        post :create, entity: { core_rules: @entity.core_rules, full_description: @entity.full_description, introduction: @entity.introduction, name: @entity.name, notes: @entity.notes, privacy: @entity.privacy, resident_id: @entity.resident_id, sheet_privacy: @entity.sheet_privacy, short_description: @entity.short_description, type: @entity.type }
      end

      assert_redirected_to entity_path(assigns(:entity))
    end

    test "should show entity" do
      get :show, id: @entity
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @entity
      assert_response :success
    end

    test "should update entity" do
      patch :update, id: @entity, entity: { core_rules: @entity.core_rules, full_description: @entity.full_description, introduction: @entity.introduction, name: @entity.name, notes: @entity.notes, privacy: @entity.privacy, resident_id: @entity.resident_id, sheet_privacy: @entity.sheet_privacy, short_description: @entity.short_description, type: @entity.type }
      assert_redirected_to entity_path(assigns(:entity))
    end

    test "should destroy entity" do
      assert_difference('Entity.count', -1) do
        delete :destroy, id: @entity
      end

      assert_redirected_to entities_path
    end
  end
end
