# frozen_string_literal: false

require 'test_helper'

module Rulebuilder
  class ItemsControllerTest < ActionController::TestCase
    setup do
      @item = items(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:items)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create item" do
      assert_difference('Item.count') do
        post :create, item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, resident_id: @item.resident_id, short_description: @item.short_description, type: @item.type, weight: @item.weight }
      end

      assert_redirected_to item_path(assigns(:item))
    end

    test "should show item" do
      get :show, id: @item
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @item
      assert_response :success
    end

    test "should update item" do
      patch :update, id: @item, item: { category: @item.category, core_rules: @item.core_rules, full_description: @item.full_description, name: @item.name, resident_id: @item.resident_id, short_description: @item.short_description, type: @item.type, weight: @item.weight }
      assert_redirected_to item_path(assigns(:item))
    end

    test "should destroy item" do
      assert_difference('Item.count', -1) do
        delete :destroy, id: @item
      end

      assert_redirected_to items_path
    end
  end
end
