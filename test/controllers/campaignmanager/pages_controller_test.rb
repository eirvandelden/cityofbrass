# frozen_string_literal: false

require 'test_helper'

module Campaignmanager
  class PagesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Campaignmanager::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @parent_object = campaignmanager_campaigns(:resident_one)

      @page = campaignmanager_pages(:adventure_log_one)
      @page2 = campaignmanager_pages(:adventure_log_two)
    end

    test "should not get index" do
      get :index, params: { campaign_id: @parent_object, type: @page.type.demodulize }
      assert_response 403
    end

    test "should get index" do
      sign_in @user
      get :index, params: { campaign_id: @parent_object, type: @page.type.demodulize }
      assert_response :success
      assert_not_nil assigns(:pages)
    end

    test "should not get new" do
      get :new, params: { campaign_id: @parent_object, type: @page.type.demodulize }
      assert_response 302
    end

    test "should get new" do
      sign_in @user
      get :new, params: { campaign_id: @parent_object, type: @page.type.demodulize }
      assert_response :success
    end

    test "should not create page" do
      assert_difference('Page.count', 0) do
        post :create, params: { adventure_log: { name: @page.name, privacy: @page.privacy, page_label: @page.page_label, short_description: @page.short_description, full_description: @page.full_description }, campaign_id: @parent_object, type: @page.type.demodulize }
      end
      assert_response 302
    end

    test "should create page" do
      sign_in @user
      assert_difference('Page.count') do
        post :create, params: { adventure_log: { name: "#{@page2.name}2", privacy: @page2.privacy, page_label: @page2.page_label, short_description: @page2.short_description, full_description: @page2.full_description }, campaign_id: @parent_object, type: @page.type.demodulize }
      end
      assert_redirected_to edit_campaign_adventure_log_path(assigns(:page), campaign_id: @parent_object, type: @page.type.demodulize)
    end

    test "should create page with parent" do
      sign_in @user
      assert_difference('Page.count') do
        post :create, params: { adventure_log: { parent: @page2.parent, name: "#{@page2.name}2", privacy: @page2.privacy, page_label: @page2.page_label, short_description: @page2.short_description, full_description: @page2.full_description }, campaign_id: @parent_object, type: @page.type.demodulize }
      end
      assert_redirected_to edit_campaign_adventure_log_path(assigns(:page), campaign_id: @parent_object, type: @page.type.demodulize)
    end

    test "should not show page" do
      get :show, params: { id: @page.id, campaign_id: @parent_object, type: @page.type.demodulize }
      assert_response 404
    end

    test "should show page" do
      sign_in @user
      get :show, params: { id: @page.id, campaign_id: @parent_object, type: @page.type.demodulize }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, params: { id: @page.id, campaign_id: @parent_object, type: @page.type.demodulize }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, params: { id: @page.id, campaign_id: @parent_object, type: @page.type.demodulize }
      assert_response :success
    end

    test "should not update page" do
      sign_in @user2
      patch :update, format: :js, params: { id: @page.id, adventure_log: { name: @page.name, privacy: @page.privacy, page_label: @page.page_label, short_description: @page.short_description, full_description: @page.full_description }, campaign_id: @parent_object, type: @page.type.demodulize }
      assert_response 403
    end

    test "should update page" do
      sign_in @user
      patch :update, xhr: true, format: :js, params: { id: @page.id, adventure_log: { name: @page.name, privacy: @page.privacy, page_label: @page.page_label, short_description: @page.short_description, full_description: @page.full_description }, campaign_id: @parent_object, type: @page.type.demodulize }
      assert_response :success
    end

    test "should not destroy page" do
      sign_in @user2
      assert_difference('Page.count', 0) do
        delete :destroy, params: { id: @page.id, campaign_id: @parent_object, type: @page.type.demodulize }
      end
      assert_response 403
    end

    test "should destroy page" do
      sign_in @user
      assert_difference('Page.count', -1) do
        delete :destroy, params: { id: @page.id, adventure_log: { name: @page.name }, campaign_id: @parent_object, type: @page.type.demodulize }
      end
      assert_redirected_to campaign_adventure_logs_path
    end

  end
end
