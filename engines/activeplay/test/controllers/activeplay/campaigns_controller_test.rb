# frozen_string_literal: false

require 'test_helper'

module Activeplay
  class CampaignsControllerTest < ActionController::TestCase
    setup do
      @campaign = activeplay_campaigns(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:campaigns)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create campaign" do
      assert_difference('Campaign.count') do
        post :create, campaign: { campaignmanager_campaign_id: @campaign.campaignmanager_campaign_id }
      end

      assert_redirected_to campaign_path(assigns(:campaign))
    end

    test "should show campaign" do
      get :show, id: @campaign
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @campaign
      assert_response :success
    end

    test "should update campaign" do
      patch :update, id: @campaign, campaign: { campaignmanager_campaign_id: @campaign.campaignmanager_campaign_id }
      assert_redirected_to campaign_path(assigns(:campaign))
    end

    test "should destroy campaign" do
      assert_difference('Campaign.count', -1) do
        delete :destroy, id: @campaign
      end

      assert_redirected_to campaigns_path
    end
  end
end
