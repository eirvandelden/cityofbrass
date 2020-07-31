# frozen_string_literal: false

require 'test_helper'

module Rulebuilder
  class districtsControllerTest < ActionController::TestCase
    setup do
      @district = districts(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:districts)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create district" do
      assert_difference('district.count') do
        post :create, district: { benefit: @district.benefit, core_rules: @district.core_rules, full_description: @district.full_description, name: @district.name, normal: @district.normal, prerequisites: @district.prerequisites, resident_id: @district.resident_id, short_description: @district.short_description, special: @district.special, type: @district.type }
      end

      assert_redirected_to district_path(assigns(:district))
    end

    test "should show district" do
      get :show, id: @district
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @district
      assert_response :success
    end

    test "should update district" do
      patch :update, id: @district, district: { benefit: @district.benefit, core_rules: @district.core_rules, full_description: @district.full_description, name: @district.name, normal: @district.normal, prerequisites: @district.prerequisites, resident_id: @district.resident_id, short_description: @district.short_description, special: @district.special, type: @district.type }
      assert_redirected_to district_path(assigns(:district))
    end

    test "should destroy district" do
      assert_difference('district.count', -1) do
        delete :destroy, id: @district
      end

      assert_redirected_to districts_path
    end
  end
end
