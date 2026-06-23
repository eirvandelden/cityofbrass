require 'test_helper'

module Storybuilder
  class ResidentAdventuresControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Storybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @adventure = storybuilder_adventures(:resident_one)
      @adventure2 = storybuilder_adventures(:resident_two)
    end

    test "should not get index" do
      get :index
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index
      assert_response :success
      assert_not_nil assigns(:adventures)
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

    test "should not create adventure" do
      assert_difference('Adventure.count', 0) do
        post :create, params: { resident_adventure: { resident_id: @adventure.resident_id, name: @adventure.name, privacy: @adventure.privacy, short_description: @adventure.short_description, full_description: @adventure.full_description.to_s, type: @adventure.type } }
      end
      assert_response 302
    end

    test "should create adventure" do
      sign_in @user
      assert_difference('Adventure.count') do
        post :create, params: { resident_adventure: { resident_id: @adventure2.resident_id, name: "#{@adventure2.name}2", privacy: @adventure2.privacy, short_description: @adventure2.short_description, full_description: @adventure2.full_description.to_s, type: @adventure2.type } }
      end
      assert_redirected_to edit_resident_adventure_path(assigns(:adventure))
    end

    test "should not create second adventure for free user" do
      sign_in @user2
      assert_difference('Adventure.count', 0) do
        post :create, params: { resident_adventure: { resident_id: @adventure2.resident_id, name: "#{@adventure2.name}2", privacy: @adventure2.privacy, short_description: @adventure2.short_description, full_description: @adventure2.full_description.to_s, type: @adventure2.type } }
      end
      assert_redirected_to "/billing/subscriptions"
    end

    test "should create adventure with parent" do
      sign_in @user
      assert_difference('Adventure.count') do
        post :create, params: { resident_adventure: { resident_id: @adventure2.resident_id, name: "#{@adventure2.name}2", privacy: @adventure2.privacy, parent_id: @adventure.id, short_description: @adventure2.short_description, full_description: @adventure2.full_description.to_s, type: @adventure2.type } }
      end
      assert_redirected_to edit_resident_adventure_path(assigns(:adventure))
    end

    test "should not show residents adventure when logged out" do
      get :show, params: { id: @adventure }
      assert_response 403
    end

    test "should not show private adventure" do
      sign_in @user
      get :show, params: { id: @adventure2 }
      assert_response 403
    end

    test "should show adventure" do
      sign_in @user
      get :show, params: { id: @adventure }
      assert_response :success
    end

    test "should show public adventure when logged out" do
      @adventure.update!(privacy: 'Public')
      get :show, params: { id: @adventure }
      assert_response :success
    end

    test "should hide private child adventures when public adventure is shown logged out" do
      @adventure.update!(privacy: 'Public')
      @adventure.features.create!(feature_label: 'Children', feature_type: 'child')
      @adventure2.update!(parent_id: @adventure.id, privacy: 'Private')

      get :show, params: { id: @adventure }

      assert_response :success
      assert_no_match @adventure2.name, @response.body
    end

    test "should hide private parent adventure when public child adventure is shown logged out" do
      @adventure2.update!(full_description: '<p>Private parent adventure text</p>')
      @adventure.update!(parent_id: @adventure2.id, privacy: 'Public')

      get :show, params: { id: @adventure }

      assert_response :success
      assert_no_match @adventure2.name, @response.body
      assert_no_match @adventure2.full_description.to_s, @response.body
    end

    test "should hide private notable entity when public adventure is shown logged out" do
      entity = entitybuilder_entities(:resident_character_one)
      entity.update!(name: 'Private Notable Character', privacy: 'Private', sheet_privacy: 'Private')
      @adventure.update!(privacy: 'Public')
      @adventure.notables.create!(entity: entity, name: entity.name, sort_order: 99)

      get :show, params: { id: @adventure }

      assert_response :success
      assert_no_match entity.name, @response.body
    end

    test "should not show private adventure when logged out" do
      get :show, params: { id: @adventure2 }
      assert_response 403
    end

    test "should not show private adventure in public campaign when logged out" do
      campaign = campaignmanager_campaigns(:resident_two)

      get :campaign, params: { resident_adventure_id: @adventure2.id, campaign_id: campaign.id }

      assert_response 403
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, params: { id: @adventure }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, params: { id: @adventure }
      assert_response :success
    end

    test "should not update adventure" do
      sign_in @user2
      patch :update, params: { id: @adventure, resident_adventure: { resident_id: @adventure.resident_id, name: @adventure.name, privacy: @adventure.privacy, short_description: @adventure.short_description, full_description: @adventure.full_description.to_s, type: @adventure.type } }
      assert_response 403
    end

    test "should update adventure" do
      sign_in @user
      patch :update, params: { id: @adventure, resident_adventure: { resident_id: @adventure.resident_id, name: @adventure.name, privacy: @adventure.privacy, short_description: @adventure.short_description, full_description: @adventure.full_description.to_s, type: @adventure.type } }
      assert_redirected_to edit_resident_adventure_path(assigns(:adventure))
    end

    test "should not destroy adventure" do
      sign_in @user2
      assert_difference('Adventure.count', 0) do
        delete :destroy, params: { id: @adventure, resident_adventure: { name: @adventure.name } }
      end
      assert_response 403
    end

    test "should destroy adventure" do
      sign_in @user
      assert_difference('Adventure.count', -1) do
        delete :destroy, params: { id: @adventure, resident_adventure: { name: @adventure.name } }
      end
      assert_redirected_to resident_adventures_path
    end

  end
end
