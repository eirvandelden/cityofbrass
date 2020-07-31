# frozen_string_literal: false

require 'test_helper'

module Rulebuilder
  class SpellsControllerTest < ActionController::TestCase
    setup do
      @spell = spells(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:spells)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create spell" do
      assert_difference('Spell.count') do
        post :create, spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, resident_id: @spell.resident_id, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type }
      end

      assert_redirected_to spell_path(assigns(:spell))
    end

    test "should show spell" do
      get :show, id: @spell
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @spell
      assert_response :success
    end

    test "should update spell" do
      patch :update, id: @spell, spell: { area: @spell.area, casting_time: @spell.casting_time, components: @spell.components, core_rules: @spell.core_rules, duration: @spell.duration, effect: @spell.effect, full_description: @spell.full_description, levels: @spell.levels, name: @spell.name, range: @spell.range, resident_id: @spell.resident_id, saving_throw: @spell.saving_throw, spell_resistance: @spell.spell_resistance, school: @spell.school, short_description: @spell.short_description, target: @spell.target, type: @spell.type }
      assert_redirected_to spell_path(assigns(:spell))
    end

    test "should destroy spell" do
      assert_difference('Spell.count', -1) do
        delete :destroy, id: @spell
      end

      assert_redirected_to spells_path
    end
  end
end
