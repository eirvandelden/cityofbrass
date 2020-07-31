# frozen_string_literal: false

require 'test_helper'

module Rulebuilder
  class ProprietaryItemsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Rulebuilder::Engine.routes
      @user = users(:dan)
      @admin = admins(:dan)

      @item = rulebuilder_items(:proprietary_one)
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
      assert_not_nil assigns(:items)
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

    test "should create item" do
      sign_in @user
      sign_in @admin
      assert_difference('Item.count') do
        post :create, params: { proprietary_item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, short_description: @item.short_description, weight: @item.weight, type: @item.type, publisher: @item.publisher, is_3pp: @item.is_3pp, source: @item.source, tags: @item.tags } }
      end
      assert_redirected_to edit_proprietary_item_path(assigns(:item))
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

    test "should show.js item" do
      sign_in @user
      get :show, xhr: true, format: :js, params: { id: @item }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user
      get :edit, params: { id: @item }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      sign_in @admin
      get :edit, params: { id: @item }
      assert_response :success
    end

    test "should not update item" do
      sign_in @user
      patch :update, params: { id: @item, proprietary_item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, short_description: @item.short_description, weight: @item.weight, type: @item.type, publisher: @item.publisher, is_3pp: @item.is_3pp, source: @item.source, tags: @item.tags } }
      assert_response 403
    end

    test "should update item" do
      sign_in @user
      sign_in @admin
      patch :update, params: { id: @item, proprietary_item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, short_description: @item.short_description, weight: @item.weight, type: @item.type, publisher: @item.publisher, is_3pp: @item.is_3pp, source: @item.source, tags: @item.tags } }
      assert_redirected_to edit_proprietary_item_path(assigns(:item))
    end

    test "should not update.js item" do
      sign_in @user
      patch :update, format: :js, params: { id: @item, proprietary_item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, short_description: @item.short_description, weight: @item.weight, type: @item.type, publisher: @item.publisher, is_3pp: @item.is_3pp, source: @item.source, tags: @item.tags } }
      assert_response 403
    end

    test "should update.js item" do
      sign_in @user
      sign_in @admin
      patch :update, format: :js, params: { id: @item, proprietary_item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, short_description: @item.short_description, weight: @item.weight, type: @item.type, publisher: @item.publisher, is_3pp: @item.is_3pp, source: @item.source, tags: @item.tags } }
      assert_response :success
    end

    test "should not destroy item" do
      sign_in @user
      assert_difference('Item.count', 0) do
        delete :destroy, params: { id: @item, proprietary_item: { name: @item.name } }
      end
      assert_response 403
    end

    test "should destroy item" do
      sign_in @user
      sign_in @admin
      assert_difference('Item.count', -1) do
        delete :destroy, params: { id: @item, proprietary_item: { name: @item.name } }
      end
      assert_redirected_to proprietary_items_path
    end
  end
end
