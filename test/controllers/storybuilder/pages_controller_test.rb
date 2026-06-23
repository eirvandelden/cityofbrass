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
        post :create, params: { encounter: { name: @page.name, privacy: @page.privacy, page_label: @page.page_label, short_description: @page.short_description, full_description: @page.full_description.to_s, tags: @page.tags }, resident_adventure_id: @parent_object }
      end
      assert_response 302
    end

    test "should create page" do
      sign_in @user
      assert_difference('Page.count') do
        post :create, params: { page: { name: "#{@page2.name}2", privacy: @page2.privacy, page_label: @page2.page_label, short_description: @page2.short_description, full_description: @page2.full_description.to_s, tags: @page2.tags }, resident_adventure_id: @parent_object }
      end
      assert_redirected_to edit_resident_adventure_page_path(assigns(:page), resident_adventure_id: @parent_object)
    end

    test "should create page with parent" do
      sign_in @user
      assert_difference('Page.count') do
        post :create, params: { page: { parent: @page2.parent, name: "#{@page2.name}2", privacy: @page2.privacy, page_label: @page2.page_label, short_description: @page2.short_description, full_description: @page2.full_description.to_s, tags: @page2.tags }, resident_adventure_id: @parent_object }
      end
      assert_redirected_to edit_resident_adventure_page_path(assigns(:page), resident_adventure_id: @parent_object)
    end

    test "should not show page" do
      get :show, params: { id: @page.id, resident_adventure_id: @parent_object }
      assert_response 403
    end

    test "should show public page when logged out" do
      @page.update!(privacy: 'Public')
      get :show, params: { id: @page.id, resident_adventure_id: @parent_object }
      assert_response :success
    end

    test "should hide private tagged pages when public page is shown logged out" do
      @page.update!(privacy: 'Public')
      private_page = @parent_object.pages.create!(
        name: 'Secret Spoilers',
        privacy: 'Private',
        short_description: 'Secret',
        full_description: '<p>Secret</p>',
        tags: [ 'secret' ]
      )
      @page.features.create!(
        feature_label: 'Tagged',
        feature_type: 'tag',
        record_type: 'Storybuilder',
        search_tags: 'secret'
      )

      get :show, params: { id: @page.id, resident_adventure_id: @parent_object }

      assert_response :success
      assert_no_match private_page.name, @response.body
    end

    test "should hide private parent page when public child page is shown logged out" do
      private_page = @parent_object.pages.create!(
        name: 'Private Parent Page',
        privacy: 'Private',
        short_description: 'Secret',
        full_description: '<p>Secret parent text</p>'
      )
      child_page = @parent_object.pages.create!(
        parent_id: private_page.id,
        name: 'Public Child Page',
        privacy: 'Public',
        short_description: 'Public',
        full_description: '<p>Public child text</p>'
      )
      menu_item = @parent_object.menu_items.create!(
        item_label: private_page.name,
        item_link: "/pages/#{private_page.slug}",
        sort_order: 99
      )
      Storybuilder::MenuItemJoin.create!(menu_item: menu_item, menu_item_joinable: private_page)

      get :show, params: { id: child_page.id, resident_adventure_id: @parent_object }

      assert_response :success
      assert_no_match private_page.name, @response.body
      assert_no_match private_page.full_description.to_s, @response.body
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
      patch :update, format: :js, params: { id: @page.id, page: { name: @page.name, privacy: @page.privacy, page_label: @page.page_label, short_description: @page.short_description, full_description: @page.full_description.to_s, tags: @page.tags }, resident_adventure_id: @parent_object }
      assert_response 403
    end

    test "should update page" do
      sign_in @user
      patch :update, xhr: true, format: :js, params: { id: @page.id, page: { name: @page.name, privacy: @page.privacy, page_label: @page.page_label, short_description: @page.short_description, full_description: @page.full_description.to_s, tags: @page.tags }, resident_adventure_id: @parent_object }
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
        delete :destroy, params: { id: @page.id, resident_adventure_id: @parent_object }
      end
      assert_redirected_to resident_adventure_pages_path
    end

  end
end
