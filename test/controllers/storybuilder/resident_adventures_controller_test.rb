require 'test_helper'

module Storybuilder
  class ResidentAdventuresControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Storybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @adventure = storybuilder_adventures(:resident_one)
      @adventure2 = storybuilder_adventures(:resident_two)
    end

    test "should not get index" do
      get :index
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index
      assert_response :success
      assert_not_nil assigns(:adventures)
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

    test "should not create adventure" do
      assert_difference('Adventure.count', 0) do
        post :create, params: { resident_adventure: { resident_id: @adventure.resident_id, name: @adventure.name, privacy: @adventure.privacy, short_description: @adventure.short_description, full_description: @adventure.full_description, type: @adventure.type } }
      end
      assert_response 302
    end

    test "should create adventure" do
      sign_in @user
      assert_difference('Adventure.count') do
        post :create, params: { resident_adventure: { resident_id: @adventure2.resident_id, name: "#{@adventure2.name}2", privacy: @adventure2.privacy, short_description: @adventure2.short_description, full_description: @adventure2.full_description, type: @adventure2.type } }
      end
      assert_redirected_to edit_resident_adventure_path(assigns(:adventure))
    end

    test "should not create second adventure for free user" do
      sign_in @user2
      assert_difference('Adventure.count', 0) do
        post :create, params: { resident_adventure: { resident_id: @adventure2.resident_id, name: "#{@adventure2.name}2", privacy: @adventure2.privacy, short_description: @adventure2.short_description, full_description: @adventure2.full_description, type: @adventure2.type } }
      end
      assert_redirected_to "/billing/subscriptions"
    end

    test "should create adventure with parent" do
      sign_in @user
      assert_difference('Adventure.count') do
        post :create, params: { resident_adventure: { resident_id: @adventure2.resident_id, name: "#{@adventure2.name}2", privacy: @adventure2.privacy, parent_id: @adventure.id, short_description: @adventure2.short_description, full_description: @adventure2.full_description, type: @adventure2.type } }
      end
      assert_redirected_to edit_resident_adventure_path(assigns(:adventure))
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
      sign_in @user2
      get :edit, params: { id: @adventure }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, params: { id: @adventure }
      assert_response :success
    end

    test "should not update adventure" do
      sign_in @user2
      patch :update, params: { id: @adventure, resident_adventure: { resident_id: @adventure.resident_id, name: @adventure.name, privacy: @adventure.privacy, short_description: @adventure.short_description, full_description: @adventure.full_description, type: @adventure.type } }
      assert_response 403
    end

    test "should update adventure" do
      sign_in @user
      patch :update, params: { id: @adventure, resident_adventure: { resident_id: @adventure.resident_id, name: @adventure.name, privacy: @adventure.privacy, short_description: @adventure.short_description, full_description: @adventure.full_description, type: @adventure.type } }
      assert_redirected_to edit_resident_adventure_path(assigns(:adventure))
    end

    test "should not destroy adventure" do
      sign_in @user2
      assert_difference('Adventure.count', 0) do
        delete :destroy, params: { id: @adventure, resident_adventure: { name: @adventure.name } }
      end
      assert_response 403
    end

    test "should destroy adventure" do
      sign_in @user
      assert_difference('Adventure.count', -1) do
        delete :destroy, params: { id: @adventure, resident_adventure: { name: @adventure.name } }
      end
      assert_redirected_to resident_adventures_path
    end

  end
end
