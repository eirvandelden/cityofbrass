# frozen_string_literal: false

require 'test_helper'

module Rulebuilder
  class ResidentItemsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Rulebuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @item = rulebuilder_items(:resident_one)
    end

    test "should not get index" do
      get :index
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index
      assert_response :success
      assert_not_nil assigns(:items)
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

    test "should not create item" do
      assert_difference('Item.count', 0) do
        post :create, params: { resident_item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, resident_id: @item.resident_id, short_description: @item.short_description, weight: @item.weight, type: @item.type, publisher: @item.publisher, is_3pp: @item.is_3pp, source: @item.source, tags: @item.tags } }
      end
      assert_response 302
    end

    test "should create item" do
      sign_in @user
      assert_difference('Item.count') do
        post :create, params: { resident_item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, resident_id: @item.resident_id, short_description: @item.short_description, weight: @item.weight, type: @item.type, publisher: @item.publisher, is_3pp: @item.is_3pp, source: @item.source, tags: @item.tags } }
      end
      assert_redirected_to edit_resident_item_path(assigns(:item))
    end

    test "should not show item" do
      get :show, params: { id: @item }
      assert_response 302
    end

    test "should show item" do
      sign_in @user
      get :show, params: { id: @item }
      assert_response :success
    end

    test "should not show.js item" do
      get :show, xhr: true, format: :js, params: { id: @item }
      assert_response 401
    end

    test "should show.js item" do
      sign_in @user
      get :show, xhr: true, format: :js, params: { id: @item }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, params: { id: @item }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, params: { id: @item }
      assert_response :success
    end

    test "should not update item" do
      sign_in @user2
      patch :update, params: { id: @item, resident_item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, resident_id: @item.resident_id, short_description: @item.short_description, weight: @item.weight, type: @item.type, publisher: @item.publisher, is_3pp: @item.is_3pp, source: @item.source, tags: @item.tags } }
      assert_response 403
    end

    test "should update item" do
      sign_in @user
      patch :update, params: { id: @item, resident_item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, resident_id: @item.resident_id, short_description: @item.short_description, weight: @item.weight, type: @item.type, publisher: @item.publisher, is_3pp: @item.is_3pp, source: @item.source, tags: @item.tags } }
      assert_redirected_to edit_resident_item_path(assigns(:item))
    end

    test "should not update.js item" do
      sign_in @user2
      patch :update, format: :js, params: { id: @item, resident_item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, resident_id: @item.resident_id, short_description: @item.short_description, weight: @item.weight, type: @item.type, publisher: @item.publisher, is_3pp: @item.is_3pp, source: @item.source, tags: @item.tags } }
      assert_response 403
    end

    test "should update.js item" do
      sign_in @user
      patch :update, format: :js, params: { id: @item, resident_item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, resident_id: @item.resident_id, short_description: @item.short_description, weight: @item.weight, type: @item.type, publisher: @item.publisher, is_3pp: @item.is_3pp, source: @item.source, tags: @item.tags } }
      assert_response :success
    end

    test "should not destroy item" do
      sign_in @user2
      assert_difference('Item.count', 0) do
        delete :destroy, params: { id: @item, resident_item: { name: @item.name } }
      end
      assert_response 403
    end

    test "should destroy item" do
      sign_in @user
      assert_difference('Item.count', -1) do
        delete :destroy, params: { id: @item, resident_item: { name: @item.name } }
      end
      assert_redirected_to resident_items_path
    end
  end
end
