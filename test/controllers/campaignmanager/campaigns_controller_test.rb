# frozen_string_literal: false

require 'test_helper'

module Campaignmanager
  class CampaignsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Campaignmanager::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @campaign = campaignmanager_campaigns(:resident_one)
      @campaign2 = campaignmanager_campaigns(:resident_two)
    end

    test "should not get index" do
      get :index
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index
      assert_response :success
      assert_not_nil assigns(:campaigns)
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

    test "should not create campaign" do
      assert_difference('Campaign.count', 0) do
        post :create, params: { campaign: { resident_id: @campaign.resident_id, name: @campaign.name, privacy: @campaign.privacy, short_description: @campaign.short_description, full_description: @campaign.full_description } }
      end
      assert_response 302
    end

    test "should create campaign" do
      sign_in @user
      assert_difference('Campaign.count') do
        post :create, params: { campaign: { resident_id: @campaign.resident_id, name: "#{@campaign.name}2", privacy: @campaign.privacy, short_description: @campaign.short_description, full_description: @campaign.full_description } }
      end
      assert_redirected_to edit_campaign_path(assigns(:campaign))
    end

    test "should not create second campaign for free user" do
      sign_in @user2
      assert_difference('Campaign.count', 0) do
        post :create, params: { campaign: { resident_id: @campaign.resident_id, name: "#{@campaign.name}2", privacy: @campaign.privacy, short_description: @campaign.short_description, full_description: @campaign.full_description } }
      end
      assert_redirected_to "/billing/subscriptions"
    end

    test "should not show campaign" do
      get :show, params: { id: @campaign }
      assert_response 403
    end

    test "should show campaign" do
      sign_in @user
      get :show, params: { id: @campaign }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, params: { id: @campaign }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, params: { id: @campaign }
      assert_response :success
    end

    test "should not update campaign" do
      sign_in @user2
      patch :update, params: { id: @campaign, campaign: { resident_id: @campaign.resident_id, name: @campaign.name, privacy: @campaign.privacy, short_description: @campaign.short_description, full_description: @campaign.full_description } }
      assert_response 403
    end

    test "should update campaign" do
      sign_in @user
      patch :update, params: { id: @campaign, campaign: { resident_id: @campaign.resident_id, name: @campaign.name, privacy: @campaign.privacy, short_description: @campaign.short_description, full_description: @campaign.full_description } }
      assert_redirected_to edit_campaign_path(assigns(:campaign))
    end

    test "should not destroy campaign" do
      sign_in @user2
      assert_difference('Campaign.count', 0) do
        delete :destroy, params: { id: @campaign, campaign: { name: @campaign.name } }
      end
      assert_response 403
    end

    test "should destroy campaign" do
      sign_in @user
      assert_difference('Campaign.count', -1) do
        delete :destroy, params: { id: @campaign, campaign: { name: @campaign.name } }
      end
      assert_redirected_to "/residents/#{@campaign.resident.slug}/campaigns"
    end

  end
end
