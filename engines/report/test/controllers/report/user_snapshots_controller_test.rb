require 'test_helper'

module Report
  class UserSnapshotsControllerTest < ActionController::TestCase
    setup do
      @user_snapshot = user_snapshots(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:user_snapshots)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create user_snapshot" do
      assert_difference('UserSnapshot.count') do
        post :create, user_snapshot: {  }
      end

      assert_redirected_to user_snapshot_path(assigns(:user_snapshot))
    end

    test "should show user_snapshot" do
      get :show, id: @user_snapshot
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @user_snapshot
      assert_response :success
    end

    test "should update user_snapshot" do
      patch :update, id: @user_snapshot, user_snapshot: {  }
      assert_redirected_to user_snapshot_path(assigns(:user_snapshot))
    end

    test "should destroy user_snapshot" do
      assert_difference('UserSnapshot.count', -1) do
        delete :destroy, id: @user_snapshot
      end

      assert_redirected_to user_snapshots_path
    end
  end
end
