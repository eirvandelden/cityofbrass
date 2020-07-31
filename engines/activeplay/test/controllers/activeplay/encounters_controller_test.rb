# frozen_string_literal: false

require 'test_helper'

module Activeplay
  class EncountersControllerTest < ActionController::TestCase
    setup do
      @encounter = activeplay_encounters(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:encounters)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create encounter" do
      assert_difference('Encounter.count') do
        post :create, encounter: { entity_id: @encounter.entity_id, name: @encounter.name, sort_order: @encounter.sort_order, virtual_table_id: @encounter.virtual_table_id }
      end

      assert_redirected_to encounter_path(assigns(:encounter))
    end

    test "should show encounter" do
      get :show, id: @encounter
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @encounter
      assert_response :success
    end

    test "should update encounter" do
      patch :update, id: @encounter, encounter: { entity_id: @encounter.entity_id, name: @encounter.name, sort_order: @encounter.sort_order, virtual_table_id: @encounter.virtual_table_id }
      assert_redirected_to encounter_path(assigns(:encounter))
    end

    test "should destroy encounter" do
      assert_difference('Encounter.count', -1) do
        delete :destroy, id: @encounter
      end

      assert_redirected_to encounters_path
    end
  end
end
