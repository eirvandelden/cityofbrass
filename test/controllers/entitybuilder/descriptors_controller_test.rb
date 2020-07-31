# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class DescriptorsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @character = entitybuilder_entities(:resident_character_one)
      @descriptor = entitybuilder_descriptors(:one)
    end

    test "should not get index" do
      get :index, params: { resident_character_id: @character.id }
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index, params: { resident_character_id: @character.id }
      assert_response :success
      assert_not_nil assigns(:descriptors)
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

    test "should not create descriptor" do
      assert_difference('Descriptor.count', 0) do
        post :create, format: :js, params: { descriptor: { name: 'NewName' }, resident_character_id: @character.id }
      end
      assert_response 401
    end

    test "should create descriptor 1" do
      sign_in @user
      assert_difference('Descriptor.count') do
        post :create, format: :js, params: { descriptor: { sort_order: 0, name: 'Descriptor1' }, resident_character_id: @character.id }
      end
      assert_response :success
    end

    test "should create descriptor 2" do
      sign_in @user
      assert_difference('Descriptor.count') do
        post :create, format: :js, params: { descriptor: { sort_order: 1, name: 'Descriptor2', description: @descriptor.description, is_private: @descriptor.is_private }, resident_character_id: @character.id }
      end
      assert_response :success
    end

    test "should not show descriptor" do
      get :show, xhr: true, format: :js, params: { id: @descriptor, resident_character_id: @character.id }
      assert_response 401
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, xhr: true, format: :js, params: { id: @descriptor, resident_character_id: @character.id }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, xhr: true, format: :js, params: { id: @descriptor, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not update descriptor" do
      sign_in @user2
      patch :update, xhr: true, format: :js, params: { id: @descriptor, descriptor: { name: @descriptor.name }, resident_character_id: @character.id }
      assert_response 403
    end

    test "should update descriptor" do
      sign_in @user
      patch :update, xhr: true, format: :js, params: { id: @descriptor, descriptor: { name: @descriptor.name }, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not destroy descriptor" do
      sign_in @user2
      assert_difference('Descriptor.count', 0) do
        delete :destroy, format: :js, params: { id: @descriptor, resident_character_id: @character.id }
      end
      assert_response 403
    end

    test "should destroy descriptor" do
      sign_in @user
      assert_difference('Descriptor.count', -1) do
        delete :destroy, format: :js, params: { id: @descriptor, resident_character_id: @character.id }
      end
      assert_response :success
    end

  end
end
