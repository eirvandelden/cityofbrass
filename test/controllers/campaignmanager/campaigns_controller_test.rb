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

    test "should hide private world when public campaign is shown logged out" do
      district = worldbuilder_districts(:district_three)
      @campaign2.update!(privacy: 'Public', district: district)

      get :show, params: { id: @campaign2 }

      assert_response :success
      assert_no_match district.name, @response.body
    end

    test "should show active adventure link to anonymous visitor when adventure is public" do
      @campaign2.update!(privacy: 'Public')
      storybuilder_adventures(:resident_two).update!(privacy: 'Public')

      get :show, params: { id: @campaign2 }

      assert_response :success
      assert_match I18n.t("campaignmanager.navigation.active_adventure"), @response.body
      assert_match storybuilder_adventures(:resident_two).name, @response.body
    end

    test "should hide active adventure from anonymous visitor when adventure is private" do
      @campaign2.update!(privacy: 'Public')

      get :show, params: { id: @campaign2 }

      assert_response :success
      assert_no_match I18n.t("campaignmanager.navigation.active_adventure"), @response.body
      assert_no_match storybuilder_adventures(:resident_two).name, @response.body
    end

    test "should hide private world when public campaign is shown to another resident" do
      district = worldbuilder_districts(:district_three)
      district.update!(privacy: 'Private')
      @campaign2.update!(privacy: 'Public', district: district)

      sign_in @user2
      get :show, params: { id: @campaign2 }

      assert_response :success
      assert_no_match district.name, @response.body
    end

    test "should hide private character when public campaign characters are shown logged out" do
      character = entitybuilder_entities(:resident_character_one)
      character.update!(name: 'Hidden Campaign Character', privacy: 'Private', sheet_privacy: 'Private')
      character.campaign_join&.destroy!
      character.create_campaign_join!(campaign: @campaign2)
      @campaign2.update!(privacy: 'Public')

      get :characters, params: { campaign_id: @campaign2 }

      assert_response :success
      assert_no_match character.name, @response.body
    end

    test "should hide private notable entity when public campaign notables are shown logged out" do
      entity = entitybuilder_entities(:resident_character_one)
      entity.update!(
        name: 'Hidden Campaign Notable Character',
        privacy: 'Private',
        sheet_privacy: 'Private',
        short_description: 'Hidden campaign notable text'
      )
      @campaign2.notables.create!(entity: entity, name: entity.name, sort_order: 99)
      @campaign2.update!(privacy: 'Public')

      get :notables, params: { campaign_id: @campaign2 }

      assert_response :success
      assert_no_match entity.name, @response.body
      assert_no_match entity.short_description, @response.body
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

    test "should update campaign adventures" do
      sign_in @user
      adventure = storybuilder_adventures(:resident_one)
      patch :update, params: {
        id: @campaign,
        campaign: {
          name: @campaign.name,
          privacy: @campaign.privacy,
          adventure_ids: [ adventure.id ]
        }
      }
      assert_redirected_to edit_campaign_path(assigns(:campaign))
      assert_includes @campaign.reload.adventures, adventure
    end

    test "should set active adventure" do
      sign_in @user2
      adventure = @campaign2.adventures.first
      patch :update, params: {
        id: @campaign2,
        campaign: {
          name: @campaign2.name,
          privacy: 'Private',
          active_adventure_id: adventure.id
        }
      }
      assert_redirected_to edit_campaign_path(assigns(:campaign))
      assert_equal adventure, @campaign2.reload.active_adventure
    end

    test "should clear active adventure" do
      sign_in @user2
      patch :update, params: {
        id: @campaign2,
        campaign: {
          name: @campaign2.name,
          privacy: 'Private',
          active_adventure_id: ''
        }
      }
      assert_redirected_to edit_campaign_path(assigns(:campaign))
      assert_nil @campaign2.reload.active_adventure
    end

  end
end
