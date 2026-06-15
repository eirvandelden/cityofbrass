require 'test_helper'

module Entitybuilder
  class ResidentCharactersControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @character = entitybuilder_entities(:resident_character_one)
      @character2 = entitybuilder_entities(:resident_character_two)
    end

    test "should not get index" do
      get :index
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index
      assert_response :success
      assert_not_nil assigns(:entities)
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

    test "should not create character" do
      assert_difference('Entity.count', 0) do
        post :create, params: { resident_character: { resident_id: @character.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      end
      assert_response 302
    end

    test "should create character" do
      sign_in @user
      assert_difference('Entity.count') do
        post :create, params: { resident_character: { resident_id: @character.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      end
      assert_redirected_to edit_resident_character_path(assigns(:entity))
    end

    test "should not create third character for free user" do
      sign_in @user2
      assert_difference('Entity.count', 0) do
        post :create, params: { resident_character: { resident_id: @character2.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      end
      assert_redirected_to "/billing/subscriptions"
    end

    test "should not show character" do
      get :show, params: { id: @character }
      assert_response 403
    end

    test "should show public character when logged out" do
      @character.update!(privacy: 'Public')
      get :show, params: { id: @character }
      assert_response :success
    end

    test "should hide private campaign when public character is shown logged out" do
      campaign = campaignmanager_campaigns(:resident_two)
      @character.update!(privacy: 'Public')
      @character.campaign_join&.destroy!
      @character.create_campaign_join!(campaign: campaign)
      campaign.update!(privacy: 'Private', district: worldbuilder_districts(:district_two))

      get :show, params: { id: @character }

      assert_response :success
      assert_no_match campaign.name, @response.body
      assert_no_match campaign.resident.name, @response.body
    end

    test "should hide private campaign world when public character is shown logged out" do
      campaign = campaignmanager_campaigns(:resident_two)
      district = worldbuilder_districts(:district_three)
      @character.update!(privacy: 'Public')
      @character.campaign_join&.destroy!
      @character.create_campaign_join!(campaign: campaign)
      campaign.update!(privacy: 'Public', district: district)

      get :show, params: { id: @character }

      assert_response :success
      assert_match campaign.name, @response.body
      assert_no_match district.name, @response.body
    end

    test "should hide private campaign world when public character is shown to another resident" do
      campaign = campaignmanager_campaigns(:resident_two)
      district = worldbuilder_districts(:district_three)
      district.update!(privacy: 'Private')
      @character.update!(privacy: 'Public')
      @character.campaign_join&.destroy!
      @character.create_campaign_join!(campaign: campaign)
      campaign.update!(privacy: 'Public', district: district)

      sign_in @user2
      get :show, params: { id: @character }

      assert_response :success
      assert_match campaign.name, @response.body
      assert_no_match district.name, @response.body
    end

    test "should show public character sheet when logged out" do
      @character.update!(sheet_privacy: 'Public')
      get :sheet, params: { resident_character_id: @character }
      assert_response :success
    end

    test "should hide private inventory item when public character sheet is shown logged out" do
      inventory_item = entitybuilder_inventory_items(:one)
      inventory_item.item.update!(
        name: 'Hidden Sheet Item',
        privacy: 'Private',
        short_description: 'Hidden sheet item text'
      )
      @character.update!(sheet_privacy: 'Public')

      get :sheet, params: { resident_character_id: @character }

      assert_response :success
      assert_no_match inventory_item.item.name, @response.body
      assert_no_match inventory_item.item.short_description, @response.body
    end

    test "should not show public character card summary when sheet privacy is private" do
      @character.update!(privacy: 'Public', sheet_privacy: 'Private')
      get :card_summary, xhr: true, format: :js, params: { resident_character_id: @character }
      assert_response 403
    end

    test "should show character" do
      sign_in @user
      get :show, params: { id: @character }
      assert_response :success
    end

    test "should show character mobile" do
      request.variant = :phone
      sign_in @user
      get :show, params: { id: @character }
      assert_response :success
    end

    test "should show character sheet" do
      sign_in @user
      get :sheet, params: { resident_character_id: @character }
      assert_response :success
    end

    test "should show character profile" do
      sign_in @user
      get :sheet, params: { resident_character_id: @character }
      assert_response :success
    end

    test "should show character card" do
      sign_in @user
      get :sheet, params: { resident_character_id: @character }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, params: { id: @character }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, params: { id: @character }
      assert_response :success
    end

    test "should not update character" do
      sign_in @user2
      patch :update, params: { id: @character, resident_character: { resident_id: @character.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      assert_response 403
    end

    test "should update character" do
      sign_in @user
      patch :update, params: { id: @character, resident_character: { resident_id: @character.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      assert_redirected_to edit_resident_character_path(assigns(:entity))
    end

    test "should not update_notes.js character" do
      sign_in @user2
      patch :update_notes, format: :js, params: { resident_character_id: @character, resident_character: { resident_id: @character.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      assert_response 403
    end

    test "should update_notes.js character" do
      sign_in @user
      patch :update_notes, format: :js, params: { resident_character_id: @character, resident_character: { resident_id: @character.resident_id, name: @character.name, privacy: @character.privacy, sheet_privacy: @character.sheet_privacy, core_rules: @character.core_rules, short_description: @character.short_description, full_description: @character.full_description, notes: @character.notes, type: @character.type } }
      assert_response :success
    end

    test "should not destroy character" do
      sign_in @user2
      assert_difference('Entity.count', 0) do
        delete :destroy, params: { id: @character, resident_character: { name: @character.name } }
      end
      assert_response 403
    end

    test "should destroy character" do
      sign_in @user
      assert_difference('Entity.count', -1) do
        delete :destroy, params: { id: @character, resident_character: { name: @character.name } }
      end
      assert_redirected_to resident_characters_path
    end

  end
end
