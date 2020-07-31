# frozen_string_literal: false

require 'test_helper'

module Worldbuilder
  class PagesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Worldbuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)
      @user3 = users(:courtney)

      @parent_object = worldbuilder_districts(:district_one)

      @page = worldbuilder_pages(:page_one)
      @page2 = worldbuilder_pages(:page_two)
    end

    test "should not get index for guest" do
      get :index, params: { district_id: @parent_object.slug }
      assert_response 302
    end

    test "should not get index for resident" do
      sign_in @user3
      get :index, params: { district_id: @parent_object.slug }
      assert_response 403
    end

    test "should get index" do
      sign_in @user
      get :index, params: { district_id: @parent_object.slug }
      assert_response :success
      assert_not_nil assigns(:pages)
    end

    test "should not get new" do
      get :new, params: { district_id: @parent_object.slug }
      assert_response 302
    end

    test "should get new" do
      sign_in @user
      get :new, params: { district_id: @parent_object.slug }
      assert_response :success
    end

    test "should not create page" do
      assert_difference('Page.count', 0) do
        post :create, params: { page: { name: @page.name, page_label: @page.page_label, short_description: @page.short_description, full_description: @page.full_description, tags: @page.tags }, district_id: @parent_object.slug }
      end
      assert_response 302
    end

    test "should create page" do
      sign_in @user
      assert_difference('Page.count') do
        post :create, params: { page: { name: "#{@page2.name}2", page_label: @page2.page_label, short_description: @page2.short_description, full_description: @page2.full_description, tags: @page2.tags }, district_id: @parent_object.slug }
      end
      assert_redirected_to edit_district_page_path(assigns(:page), district_id: @parent_object.slug)
    end

    test "should create page with parent" do
      sign_in @user
      assert_difference('Page.count') do
        post :create, params: { page: { parent: @page2.parent, name: "#{@page2.name}2", page_label: @page2.page_label, short_description: @page2.short_description, full_description: @page2.full_description, tags: @page2.tags }, district_id: @parent_object.slug }
      end
      assert_redirected_to edit_district_page_path(assigns(:page), district_id: @parent_object.slug)
    end

    test "should show page for guest" do
      get :show, params: { id: @page.slug, district_id: @parent_object.slug }
      assert_response :success
    end

    test "should show page" do
      sign_in @user
      get :show, params: { id: @page.slug, district_id: @parent_object.slug }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, params: { id: @page.id, district_id: @parent_object.slug }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, params: { id: @page.id, district_id: @parent_object.slug }
      assert_response :success
    end

    test "should not update page" do
      sign_in @user2
      patch :update, params: { format: :js, id: @page.id, page: { name: @page.name, page_label: @page.page_label, short_description: @page.short_description, full_description: @page.full_description, tags: @page.tags }, district_id: @parent_object.slug }
      assert_response 403
    end

    test "should update page" do
      sign_in @user
      patch :update, xhr: true, format: :js, params: { id: @page.id, page: { name: @page.name, page_label: @page.page_label, short_description: @page.short_description, full_description: @page.full_description, tags: @page.tags }, district_id: @parent_object.slug }
      assert_response :success
    end

    test "should not destroy page" do
      sign_in @user2
      assert_difference('Page.count', 0) do
        delete :destroy, params: { id: @page.id, district_id: @parent_object.slug }
      end
      assert_response 403
    end

    test "should destroy page" do
      sign_in @user
      assert_difference('Page.count', -1) do
        delete :destroy, params: { id: @page.id, page: { name: @page.name, name_confirmation: @page.name }, district_id: @parent_object.slug }
      end
      assert_redirected_to district_pages_path
    end

  end
end
