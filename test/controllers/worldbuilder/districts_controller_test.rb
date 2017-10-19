require 'test_helper'

module Worldbuilder
  class DistrictsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Worldbuilder::Engine.routes

      @dan = users(:dan)
      @courtney = users(:courtney)
      @user2 = users(:lucas)
      @district = worldbuilder_districts(:district_one)
      @public_district = worldbuilder_districts(:district_two)
      @affiliate_district = worldbuilder_districts(:district_three)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:districts)
    end

    test "should get new" do
      sign_in @dan
      get :new
      assert_response :success
    end

    test "should create district" do
      sign_in @dan
      assert_difference('District.count') do
        post :create, params: { district: { resident_id: @district.resident_id, name: "Test World", slug: "test-world", privacy: "Affiliates" } }
      end

      assert_redirected_to "/wb/#{assigns(:district).slug}"
      assert_equal "#{assigns(:district).name} is ready for management!", flash[:notice]
    end

    test "should not create second adventure for free user" do
      sign_in @user2
      assert_difference('District.count', 0) do
        post :create, params: { district: { resident_id: @district.resident_id, name: "Test World", slug: "test-world", privacy: "Affiliates" } }
      end

      assert_redirected_to "/billing/subscriptions"
    end

    test "should show district to public" do
      get :show, params: { id: @public_district.slug }
      assert_response :success
      assert_not_nil assigns(:district)
    end

    test "should not show affiliate district to public" do
      get :show, params: { id: @affiliate_district.slug }
      assert_response 403
    end

    test "should show district" do
      sign_in @dan
      get :show, params: { id: @district.slug }
      assert_response :success
      assert_not_nil assigns(:district)

    end

    test "should not get edit" do
      sign_in @courtney
      get :edit, params: { id: @district }
      assert_response 403
    end

    test "should get edit" do
      sign_in @dan
      get :edit, params: { id: @district }
      assert_response :success
    end

    test "should update district.html" do
      sign_in @dan
      patch :update, params: { id: @district, district: { full_description: @district.full_description, name: @district.name, short_description: @district.short_description, slug: @district.slug, privacy: @district.privacy } }
      assert_redirected_to "/wb/#{assigns(:district).id}/edit"
    end

    test "should update district.js" do
      sign_in @dan
      patch :update, xhr: true, format: :js, params: { id: @district, district: { full_description: @district.full_description, name: @district.name, short_description: @district.short_description, slug: @district.slug, privacy: @district.privacy } }
      assert_response :success
    end

    test "should not destroy district" do
      sign_in @courtney
      assert_no_difference('District.count') do
        delete :destroy, params: { id: @district, district: { name: @district.name, name_confirmation: @district.name } }
      end
      assert_response 403
    end

    test "should destroy district" do
      sign_in @dan
      assert_difference('District.count', -1) do
        delete :destroy, params: { id: @district, district: { name: @district.name, name_confirmation: @district.name } }
      end
      assert_redirected_to "/residents/#{@district.resident.slug}/districts"
    end

  end
end
