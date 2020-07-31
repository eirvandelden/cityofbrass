# frozen_string_literal: false

require 'test_helper'

module Storybuilder
  class CreatureNotablesControllerTest < ActionController::TestCase
    setup do
      @creature_notable = creature_notables(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:creature_notables)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create creature_notable" do
      assert_difference('CreatureNotable.count') do
        post :create, creature_notable: { creature_id: @creature_notable.creature_id, name: @creature_notable.name, sort_order: @creature_notable.sort_order, notableable_id: @creature_notable.notableable_id, notableable_type: @creature_notable.notableable_type }
      end

      assert_redirected_to creature_notable_path(assigns(:creature_notable))
    end

    test "should show creature_notable" do
      get :show, id: @creature_notable
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @creature_notable
      assert_response :success
    end

    test "should update creature_notable" do
      patch :update, id: @creature_notable, creature_notable: { creature_id: @creature_notable.creature_id, name: @creature_notable.name, sort_order: @creature_notable.sort_order, notableable_id: @creature_notable.notableable_id, notableable_type: @creature_notable.notableable_type }
      assert_redirected_to creature_notable_path(assigns(:creature_notable))
    end

    test "should destroy creature_notable" do
      assert_difference('CreatureNotable.count', -1) do
        delete :destroy, id: @creature_notable
      end

      assert_redirected_to creature_notables_path
    end
  end
end
