# frozen_string_literal: false

require 'test_helper'

module Report
  class ResidentSnapshotsControllerTest < ActionController::TestCase
    setup do
      @resident_snapshot = resident_snapshots(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:resident_snapshots)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create resident_snapshot" do
      assert_difference('ResidentSnapshot.count') do
        post :create, resident_snapshot: {  }
      end

      assert_redirected_to resident_snapshot_path(assigns(:resident_snapshot))
    end

    test "should show resident_snapshot" do
      get :show, id: @resident_snapshot
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @resident_snapshot
      assert_response :success
    end

    test "should update resident_snapshot" do
      patch :update, id: @resident_snapshot, resident_snapshot: {  }
      assert_redirected_to resident_snapshot_path(assigns(:resident_snapshot))
    end

    test "should destroy resident_snapshot" do
      assert_difference('ResidentSnapshot.count', -1) do
        delete :destroy, id: @resident_snapshot
      end

      assert_redirected_to resident_snapshots_path
    end
  end
end
