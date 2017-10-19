require 'test_helper'

module Entitybuilder
  class TraitsControllerTest < ActionController::TestCase
    setup do
      @trait = traits(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:traits)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create trait" do
      assert_difference('Trait.count') do
        post :create, trait: { full_description: @trait.full_description, name: @trait.name, short_description: @trait.short_description, sort_order: @trait.sort_order, traitable_id: @trait.traitable_id, traitable_type: @trait.traitable_type }
      end

      assert_redirected_to trait_path(assigns(:trait))
    end

    test "should show trait" do
      get :show, id: @trait
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @trait
      assert_response :success
    end

    test "should update trait" do
      patch :update, id: @trait, trait: { full_description: @trait.full_description, name: @trait.name, short_description: @trait.short_description, sort_order: @trait.sort_order, traitable_id: @trait.traitable_id, traitable_type: @trait.traitable_type }
      assert_redirected_to trait_path(assigns(:trait))
    end

    test "should destroy trait" do
      assert_difference('Trait.count', -1) do
        delete :destroy, id: @trait
      end

      assert_redirected_to traits_path
    end
  end
end
