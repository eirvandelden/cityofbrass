# frozen_string_literal: false

require 'test_helper'

module Entitybuilder
  class KnownSpellsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Entitybuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @character = entitybuilder_entities(:resident_character_one)
      @known_spell = entitybuilder_known_spells(:one)
    end

    test "should not get index" do
      get :index, params: { resident_character_id: @character.id }
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index, params: { resident_character_id: @character.id }
      assert_response :success
      assert_not_nil assigns(:spells)
    end

    test "should not get new" do
      get :new, xhr: true, format: :js, params: { resident_character_id: @character.id }
      assert_response 401
    end

    test "should get new" do
      sign_in @user
      get :new, xhr: true, format: :js, params: { resident_character_id: @character.id }
      assert_response :success
    end

    test "should not create known_spell" do
      assert_difference('KnownSpell.count', 0) do
        post :create, format: :js, params: { known_spell: { name: 'NewName' }, resident_character_id: @character.id }
      end
      assert_response 401
    end

    test "should create known_spell 1" do
      sign_in @user
      assert_difference('KnownSpell.count') do
        post :create, format: :js, params: { known_spell: { sort_order: 0, spell_id: @known_spell.spell.id }, resident_character_id: @character.id }
      end
      assert_response :success
    end

    test "should create known_spell 2" do
      sign_in @user
      assert_difference('KnownSpell.count') do
        post :create, format: :js, params: { known_spell: { sort_order: 1, spell_id: @known_spell.spell.id, spell_class: 'Wizard', level: 1, at_will: true, prepared: true, used: false, detail: 'NewDescription' }, resident_character_id: @character.id }
      end
      assert_response :success
    end

    test "should not show known_spell" do
      get :show, xhr: true, format: :js, params: { id: @known_spell, resident_character_id: @character.id }
      assert_response 401
    end

    test "should show known_spell" do
      sign_in @user
      get :show, xhr: true, format: :js, params: { id: @known_spell, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, xhr: true, format: :js, params: { id: @known_spell, resident_character_id: @character.id }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, xhr: true, format: :js, params: { id: @known_spell, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not update known_spell" do
      sign_in @user2
      patch :update, xhr: true, format: :js, params: { id: @known_spell, known_spell: { spell_id: @known_spell.spell.id }, resident_character_id: @character.id }
      assert_response 403
    end

    test "should update known_spell" do
      sign_in @user
      patch :update, xhr: true, format: :js, params: { id: @known_spell, known_spell: { spell_id: @known_spell.spell.id }, resident_character_id: @character.id }
      assert_response :success
    end

    test "should not destroy known_spell" do
      sign_in @user2
      assert_difference('KnownSpell.count', 0) do
        delete :destroy, format: :js, params: { id: @known_spell, resident_character_id: @character.id }
      end
      assert_response 403
    end

    test "should destroy known_spell" do
      sign_in @user
      assert_difference('KnownSpell.count', -1) do
        delete :destroy, format: :js, params: { id: @known_spell, resident_character_id: @character.id }
      end
      assert_response :success
    end

  end
end
