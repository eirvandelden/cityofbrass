require 'test_helper'

module Rulebuilder
  class StockSpellsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Rulebuilder::Engine.routes
      @user = users(:dan)
      @admin = admins(:dan)

      @spell = rulebuilder_spells(:stock_one)
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
      sign_in @user
      get :new
      assert_response 403
    end

    test "should get new" do
      sign_in @user
      sign_in @admin
      get :new
      assert_response :success
    end

    test "should create spell" do
      sign_in @user
      sign_in @admin
      assert_difference('Spell.count') do
        post :create, params: { stock_spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type, publisher: @spell.publisher, is_3pp: @spell.is_3pp, source: @spell.source, tags: @spell.tags } }
      end
      assert_redirected_to edit_stock_spell_path(assigns(:spell))
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

    test "should show.js spell" do
      sign_in @user
      get :show, xhr: true, format: :js, params: { id: @spell }
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user
      get :edit, params: { id: @spell }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      sign_in @admin
      get :edit, params: { id: @spell }
      assert_response :success
    end

    test "should not update spell" do
      sign_in @user
      patch :update, params: { id: @spell, stock_spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type, publisher: @spell.publisher, is_3pp: @spell.is_3pp, source: @spell.source, tags: @spell.tags } }
      assert_response 403
    end

    test "should update spell" do
      sign_in @user
      sign_in @admin
      patch :update, params: { id: @spell, stock_spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type, publisher: @spell.publisher, is_3pp: @spell.is_3pp, source: @spell.source, tags: @spell.tags } }
      assert_redirected_to edit_stock_spell_path(assigns(:spell))
    end

    test "should not update.js spell" do
      sign_in @user
      patch :update, format: :js, params: { id: @spell, stock_spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type, publisher: @spell.publisher, is_3pp: @spell.is_3pp, source: @spell.source, tags: @spell.tags } }
      assert_response 403
    end

    test "should update.js spell" do
      sign_in @user
      sign_in @admin
      patch :update, format: :js, params: { id: @spell, stock_spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type, publisher: @spell.publisher, is_3pp: @spell.is_3pp, source: @spell.source, tags: @spell.tags } }
      assert_response :success
    end

    test "should not destroy spell" do
      sign_in @user
      assert_difference('Spell.count', 0) do
        delete :destroy, params: { id: @spell, stock_spell: { name: @spell.name } }
      end
      assert_response 403
    end

    test "should destroy spell" do
      sign_in @user
      sign_in @admin
      assert_difference('Spell.count', -1) do
        delete :destroy, params: { id: @spell, stock_spell: { name: @spell.name } }
      end
      assert_redirected_to stock_spells_path
    end
  end
end
