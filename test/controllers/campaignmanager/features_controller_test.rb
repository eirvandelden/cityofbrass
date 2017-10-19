require 'test_helper'

module Campaignmanager
  class FeaturesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Campaignmanager::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @parent_object = campaignmanager_campaigns(:resident_one)
      @feature = campaignmanager_features(:page_text1)
    end

    test "should not get index" do
      get :index, params: { campaign_id: @parent_object }
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index, params: { campaign_id: @parent_object }
      assert_response :success
      assert_not_nil assigns(:features)
    end

    #test "should not get new_feature_type" do
    #  get :new_feature_type, campaign_id: @parent_object
    #  assert_response 302
    #end

    #test "should get new" do
    #  sign_in @user
    #  get :new, campaign_id: @parent_object
    #  assert_response :success
    #end

    #test "should not create feature" do
    #  assert_difference('Campaign.count', 0) do
    #    post :create, campaign_id: @parent_object, feature: { feature_text: @feature.type, type: @feature.type }
    #  end
    #  assert_response 302
    #end

    #test "should create feature" do
    #  sign_in @user
    #  assert_difference('Campaign.count') do
    #    post :create, campaign_id: @parent_object, feature: { resident_id: @feature.resident_id, name: "#{@feature.name}2", privacy: @feature.privacy, short_description: @feature.short_description, full_description: @feature.full_description, type: @feature.type }
    #  end
    #  assert_redirected_to edit_feature_path(assigns(:feature))
    #end

    test "should not show feature" do
      get :show, params: { id: @feature, campaign_id: @parent_object }
      assert_response 403
    end

    #test "should show feature" do
    #  sign_in @user
    #  get :show, id: @feature, campaign_id: @parent_object
    #  assert_response :success
    #end

    test "should not get edit" do
      sign_in @user2
      get :edit, params: { id: @feature, campaign_id: @parent_object }
      assert_response 403
    end

    #test "should get edit" do
    #  sign_in @user
    #  get :edit, id: @feature, campaign_id: @parent_object
    #  assert_response :success
    #end

    #test "should not update feature" do
    #  sign_in @user2
    #  patch :update, id: @feature, campaign_id: @parent_object, feature: { resident_id: @feature.resident_id, name: @feature.name, privacy: @feature.privacy, short_description: @feature.short_description, full_description: @feature.full_description, type: @feature.type }
    #  assert_response 403
    #end

    #test "should update feature" do
    #  sign_in @user
    #  patch :update, id: @feature, campaign_id: @parent_object, feature: { resident_id: @feature.resident_id, name: @feature.name, privacy: @feature.privacy, short_description: @feature.short_description, full_description: @feature.full_description, type: @feature.type }
    #  assert_redirected_to edit_feature_path(assigns(:feature))
    #end

    #test "should not destroy feature" do
    #  sign_in @user2
    #  assert_difference('Campaign.count', 0) do
    #    delete :destroy, id: @feature, campaign_id: @parent_object, feature: { name: @feature.name }
    #  end
    #  assert_response 403
    #end

    #test "should destroy feature" do
    #  sign_in @user
    #  assert_difference('Campaign.count', -1) do
    #    delete :destroy, id: @feature, campaign_id: @parent_object, feature: { name: @feature.name }
    #  end
    #  assert_redirected_to features_path
    #end
  end
end
