# frozen_string_literal: false

require 'test_helper'

module Storybuilder
  class NotablesControllerTest < ActionController::TestCase
    setup do
      @notable = notables(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:notables)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create notable" do
      assert_difference('Notable.count') do
        post :create, notable: { entity_id: @notable.entity_id, name: @notable.name, sort_order: @notable.sort_order, notableable_id: @notable.notableable_id, notableable_type: @notable.notableable_type }
      end

      assert_redirected_to notable_path(assigns(:notable))
    end

    test "should show notable" do
      get :show, id: @notable
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @notable
      assert_response :success
    end

    test "should update notable" do
      patch :update, id: @notable, notable: { entity_id: @notable.entity_id, name: @notable.name, sort_order: @notable.sort_order, notableable_id: @notable.notableable_id, notableable_type: @notable.notableable_type }
      assert_redirected_to notable_path(assigns(:notable))
    end

    test "should destroy notable" do
      assert_difference('Notable.count', -1) do
        delete :destroy, id: @notable
      end

      assert_redirected_to notables_path
    end
  end
end
