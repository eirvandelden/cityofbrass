# frozen_string_literal: false

require 'test_helper'

module Report
  class GallerySnapshotsControllerTest < ActionController::TestCase
    setup do
      @gallery_snapshot = gallery_snapshots(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:gallery_snapshots)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create gallery_snapshot" do
      assert_difference('GallerySnapshot.count') do
        post :create, gallery_snapshot: {  }
      end

      assert_redirected_to gallery_snapshot_path(assigns(:gallery_snapshot))
    end

    test "should show gallery_snapshot" do
      get :show, id: @gallery_snapshot
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @gallery_snapshot
      assert_response :success
    end

    test "should update gallery_snapshot" do
      patch :update, id: @gallery_snapshot, gallery_snapshot: {  }
      assert_redirected_to gallery_snapshot_path(assigns(:gallery_snapshot))
    end

    test "should destroy gallery_snapshot" do
      assert_difference('GallerySnapshot.count', -1) do
        delete :destroy, id: @gallery_snapshot
      end

      assert_redirected_to gallery_snapshots_path
    end
  end
end
