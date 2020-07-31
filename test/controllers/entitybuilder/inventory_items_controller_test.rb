# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class InventoryItemsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @character = entitybuilder_entities(:resident_character_one)
      @inventory_item = entitybuilder_inventory_items(:one)
    end

    test "should not get index" do
      get :index, params: { resident_character_id: @character.id }
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index, params: { resident_character_id: @character.id }
      assert_response :success
      assert_not_nil assigns(:items)
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

    test "should not create inventory_item" do
      assert_difference('InventoryItem.count', 0) do
        post :create, format: :js, params: { inventory_item: { name: 'NewName' }, resident_character_id: @character.id }
      end
      assert_response 401
    end

    test "should create inventory_item 1" do
      sign_in @user
      assert_difference('InventoryItem.count') do
        post :create, format: :js, params: { inventory_item: { sort_order: 0, item_id: @inventory_item.item.id, quantity: 5 }, resident_character_id: @character.id }
      end
      assert_response :success
    end

    test "should create inventory_item 2" do
      sign_in @user
      assert_difference('InventoryItem.count') do
        post :create, format: :js, params: { inventory_item: { sort_order: 1, item_id: @inventory_item.item.id, quantity: 5, detail: 'NewDescription' }, resident_character_id: @character.id }
      end
      assert_response :success
    end

    test "should not show inventory_item" do
      get :show, xhr: true, format: :js, params: { id: @inventory_item, resident_character_id: @character.id }
      assert_response 401
    end

    test "should show inventory_item" do
      sign_in @user
      get :show, xhr: true, format: :js, params: { id: @inventory_item, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, xhr: true, format: :js, params: { id: @inventory_item, resident_character_id: @character.id }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, xhr: true, format: :js, params: { id: @inventory_item, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not update inventory_item" do
      sign_in @user2
      patch :update, xhr: true, format: :js, params: { id: @inventory_item, inventory_item: { item_id: @inventory_item.item.id }, resident_character_id: @character.id }
      assert_response 403
    end

    test "should update inventory_item" do
      sign_in @user
      patch :update, xhr: true, format: :js, params: { id: @inventory_item, inventory_item: { item_id: @inventory_item.item.id }, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not destroy inventory_item" do
      sign_in @user2
      assert_difference('InventoryItem.count', 0) do
        delete :destroy, format: :js, params: { id: @inventory_item, resident_character_id: @character.id }
      end
      assert_response 403
    end

    test "should destroy inventory_item" do
      sign_in @user
      assert_difference('InventoryItem.count', -1) do
        delete :destroy, format: :js, params: { id: @inventory_item, resident_character_id: @character.id }
      end
      assert_response :success
    end

  end
end
