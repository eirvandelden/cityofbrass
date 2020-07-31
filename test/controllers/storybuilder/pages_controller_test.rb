# frozen_string_literal: false

require 'test_helper'

module Storybuilder
  class PagesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Storybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @parent_object = storybuilder_adventures(:resident_one)

      @page = storybuilder_pages(:page_one)
      @page2 = storybuilder_pages(:page_two)
    end

    test "should not get index for guest" do
      get :index, params: { resident_adventure_id: @parent_object }
      assert_response 302
    end

    test "should not get index for resident" do
      sign_in @user2
      get :index, params: { resident_adventure_id: @parent_object }
      assert_response 403
    end

    test "should get index" do
      sign_in @user
      get :index, params: { resident_adventure_id: @parent_object }
      assert_response :success
      assert_not_nil assigns(:pages)
    end

    test "should not get new" do
      get :new, params: { resident_adventure_id: @parent_object }
      assert_response 302
    end

    test "should get new" do
      sign_in @user
      get :new, params: { resident_adventure_id: @parent_object }
      assert_response :success
    end

    test "should not create page" do
      assert_difference('Page.count', 0) do
        post :create, params: { encounter: { name: @page.name, privacy: @page.privacy, page_label: @page.page_label, short_description: @page.short_description, full_description: @page.full_description, tags: @page.tags }, resident_adventure_id: @parent_object }
      end
      assert_response 302
    end

    test "should create page" do
      sign_in @user
      assert_difference('Page.count') do
        post :create, params: { page: { name: "#{@page2.name}2", privacy: @page2.privacy, page_label: @page2.page_label, short_description: @page2.short_description, full_description: @page2.full_description, tags: @page2.tags }, resident_adventure_id: @parent_object }
      end
      assert_redirected_to edit_resident_adventure_page_path(assigns(:page), resident_adventure_id: @parent_object)
    end

    test "should create page with parent" do
      sign_in @user
      assert_difference('Page.count') do
        post :create, params: { page: { parent: @page2.parent, name: "#{@page2.name}2", privacy: @page2.privacy, page_label: @page2.page_label, short_description: @page2.short_description, full_description: @page2.full_description, tags: @page2.tags }, resident_adventure_id: @parent_object }
      end
      assert_redirected_to edit_resident_adventure_page_path(assigns(:page), resident_adventure_id: @parent_object)
    end

    test "should not show page" do
      get :show, params: { id: @page.id, resident_adventure_id: @parent_object }
      assert_response 302
    end

    test "should show page" do
      sign_in @user
      get :show, params: { id: @page.id, resident_adventure_id: @parent_object }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, params: { id: @page.id, resident_adventure_id: @parent_object }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, params: { id: @page.id, resident_adventure_id: @parent_object }
      assert_response :success
    end

    test "should not update page" do
      sign_in @user2
      patch :update, format: :js, params: { id: @page.id, page: { name: @page.name, privacy: @page.privacy, page_label: @page.page_label, short_description: @page.short_description, full_description: @page.full_description, tags: @page.tags }, resident_adventure_id: @parent_object }
      assert_response 403
    end

    test "should update page" do
      sign_in @user
      patch :update, xhr: true, format: :js, params: { id: @page.id, page: { name: @page.name, privacy: @page.privacy, page_label: @page.page_label, short_description: @page.short_description, full_description: @page.full_description, tags: @page.tags }, resident_adventure_id: @parent_object }
      assert_response :success
    end

    test "should not destroy page" do
      sign_in @user2
      assert_difference('Page.count', 0) do
        delete :destroy, params: { id: @page.id, resident_adventure_id: @parent_object }
      end
      assert_response 403
    end

    test "should destroy page" do
      sign_in @user
      assert_difference('Page.count', -1) do
        delete :destroy, params: { id: @page.id, page: { name: @page.name, name_confirmation: @page.name }, resident_adventure_id: @parent_object }
      end
      assert_redirected_to resident_adventure_pages_path
    end

  end
end
