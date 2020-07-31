# frozen_string_literal: false

require 'test_helper'

module Rulebuilder
  class ResidentSpellsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Rulebuilder::Engine.routes
      @user = users(:dan)
      @user2 = users(:lucas)

      @spell = rulebuilder_spells(:resident_one)
    end

    test "should not get index" do
      get :index
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index
      assert_response :success
      assert_not_nil assigns(:spells)
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

    test "should not create spell" do
      assert_difference('Spell.count', 0) do
        post :create, params: { resident_spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, resident_id: @spell.resident_id, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type, publisher: @spell.publisher, is_3pp: @spell.is_3pp, source: @spell.source, tags: @spell.tags } }
      end
      assert_response 302
    end

    test "should create spell" do
      sign_in @user
      assert_difference('Spell.count') do
        post :create, params: { resident_spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, resident_id: @spell.resident_id, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type, publisher: @spell.publisher, is_3pp: @spell.is_3pp, source: @spell.source, tags: @spell.tags } }
      end
      assert_redirected_to edit_resident_spell_path(assigns(:spell))
    end

    test "should not show spell" do
      get :show, params: { id: @spell }
      assert_response 302
    end

    test "should show spell" do
      sign_in @user
      get :show, params: { id: @spell }
      assert_response :success
    end

    test "should not show.js spell" do
      get :show, xhr: true, format: :js, params: { id: @spell }
      assert_response 401
    end

    test "should show.js spell" do
      sign_in @user
      get :show, xhr: true, format: :js, params: { id: @spell }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user2
      get :edit, params: { id: @spell }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      get :edit, params: { id: @spell }
      assert_response :success
    end

    test "should not update spell" do
      sign_in @user2
      patch :update, params: { id: @spell, resident_spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, resident_id: @spell.resident_id, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type, publisher: @spell.publisher, is_3pp: @spell.is_3pp, source: @spell.source, tags: @spell.tags } }
      assert_response 403
    end

    test "should update spell" do
      sign_in @user
      patch :update, params: { id: @spell, resident_spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, resident_id: @spell.resident_id, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type, publisher: @spell.publisher, is_3pp: @spell.is_3pp, source: @spell.source, tags: @spell.tags } }
      assert_redirected_to edit_resident_spell_path(assigns(:spell))
    end

    test "should not update.js spell" do
      sign_in @user2
      patch :update, format: :js, params: { id: @spell, resident_spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, resident_id: @spell.resident_id, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type, publisher: @spell.publisher, is_3pp: @spell.is_3pp, source: @spell.source, tags: @spell.tags } }
      assert_response 403
    end

    test "should update.js spell" do
      sign_in @user
      patch :update, format: :js, params: { id: @spell, resident_spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, resident_id: @spell.resident_id, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type, publisher: @spell.publisher, is_3pp: @spell.is_3pp, source: @spell.source, tags: @spell.tags } }
      assert_response :success
    end

    test "should not destroy spell" do
      sign_in @user2
      assert_difference('Spell.count', 0) do
        delete :destroy, params: { id: @spell, resident_spell: { name: @spell.name } }
      end
      assert_response 403
    end

    test "should destroy spell" do
      sign_in @user
      assert_difference('Spell.count', -1) do
        delete :destroy, params: { id: @spell, resident_spell: { name: @spell.name } }
      end
      assert_redirected_to resident_spells_path
    end
  end
end
