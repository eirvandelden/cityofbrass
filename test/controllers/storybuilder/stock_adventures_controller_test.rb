require 'test_helper'

module Storybuilder
  class StockAdventuresControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Storybuilder::Engine.routes
      @user = users(:dan)
      @admin = admins(:dan)

      @adventure = storybuilder_adventures(:stock_one)
      @adventure2 = storybuilder_adventures(:stock_two)
    end

    test "should not get index" do
      get :index
      assert_response 302
    end

    test "should get index for admin" do
      sign_in @user
      sign_in @admin
      get :index
      assert_response :success
      assert_not_nil assigns(:adventures)
    end

    test "should get stock faq for users" do
      sign_in @user
      get :index
      assert_response :success
      assert_nil assigns(:adventures)
    end

    test "should not get new" do
      get :new
      assert_response 302
    end

    test "should get new" do
      sign_in @user
      sign_in @admin
      get :new
      assert_response :success
    end

    test "should not create adventure" do
      assert_difference('Adventure.count', 0) do
        post :create, params: { stock_adventure: { name: @adventure.name, privacy: @adventure.privacy, short_description: @adventure.short_description, full_description: @adventure.full_description, type: @adventure.type } }
      end
      assert_response 302
    end

    test "should create adventure" do
      sign_in @user
      sign_in @admin
      assert_difference('Adventure.count') do
        post :create, params: { stock_adventure: { name: "#{@adventure2.name}2", privacy: @adventure2.privacy, short_description: @adventure2.short_description, full_description: @adventure2.full_description, type: @adventure2.type } }
      end
      assert_redirected_to edit_stock_adventure_path(assigns(:adventure))
    end

    test "should create adventure with parent" do
      sign_in @user
      sign_in @admin
      assert_difference('Adventure.count') do
        post :create, params: { stock_adventure: { name: "#{@adventure2.name}2", privacy: @adventure2.privacy, parent_id: @adventure.id, short_description: @adventure2.short_description, full_description: @adventure2.full_description, type: @adventure2.type } }
      end
      assert_redirected_to edit_stock_adventure_path(assigns(:adventure))
    end

    test "should not show adventure" do
      get :show, params: { id: @adventure }
      assert_response 302
    end

    test "should not show private adventure" do
      sign_in @user
      get :show, params: { id: @adventure2 }
      assert_response 403
    end

    test "should show adventure" do
      sign_in @user
      get :show, params: { id: @adventure }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user
      get :edit, params: { id: @adventure }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      sign_in @admin
      get :edit, params: { id: @adventure }
      assert_response :success
    end

    test "should not update adventure" do
      sign_in @user
      patch :update, params: { id: @adventure, stock_adventure: { name: @adventure.name, privacy: @adventure.privacy, short_description: @adventure.short_description, full_description: @adventure.full_description, type: @adventure.type } }
      assert_response 403
    end

    test "should update adventure" do
      sign_in @user
      sign_in @admin
      patch :update, params: { id: @adventure, stock_adventure: { name: @adventure.name, privacy: @adventure.privacy, short_description: @adventure.short_description, full_description: @adventure.full_description, type: @adventure.type } }
      assert_redirected_to edit_stock_adventure_path(assigns(:adventure))
    end

    test "should not destroy adventure" do
      sign_in @user
      assert_difference('Adventure.count', 0) do
        delete :destroy, params: { id: @adventure, stock_adventure: { name: @adventure.name } }
      end
      assert_response 403
    end

    test "should destroy adventure" do
      sign_in @user
      sign_in @admin
      assert_difference('Adventure.count', -1) do
        delete :destroy, params: { id: @adventure, stock_adventure: { name: @adventure.name } }
      end
      assert_redirected_to stock_adventures_path
    end

  end
end
