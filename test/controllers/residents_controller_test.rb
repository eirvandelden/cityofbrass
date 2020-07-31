# frozen_string_literal: false

require 'test_helper'

class ResidentsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @dan = users(:dan)
    @lucas = users(:lucas)
    @courtney = users(:courtney)

    @razune = residents(:razune)
    @tuandn = residents(:tuandn)
    @eleanor = residents(:eleanor)
  end

  test "should not get index" do
    get :index
    assert_response 302
    assert_redirected_to new_user_session_path
  end

  test "should get index" do
    sign_in @dan
    get :index
    assert_response :success
    assert_not_nil assigns(:residents)
  end

  test "should get new" do
    sign_in @courtney
    get :new
    assert_response :success
  end

  test "should create resident" do
    sign_in @courtney
    assert_difference('Resident.count') do
      post :create, params: { resident: { full_description: "d", name: "Keeper of the S", short_description: "d", slug: "keeper-of-the-stables", user: @courtney } }
    end
    assert_redirected_to resident_path(assigns(:resident).slug)
  end

  test "should not show resident" do
    get :show, params: { id: @razune.slug }
    assert_response 302
    assert_redirected_to new_user_session_path
  end

  test "should not show suspended resident " do
    sign_in @dan
    get :show, params: { id: @eleanor.slug }
    assert_response 302
    assert_redirected_to residents_path
  end

  test "should show resident" do
    sign_in @dan
    get :show, params: { id: @razune.slug }
    assert_response :success
    assert_not_nil assigns(:resident)
  end

  test "should show resident districts" do
    sign_in @dan
    get :districts, params: { resident_id: @razune.slug }
    assert_response :success
    assert_not_nil assigns(:resident)
  end

  test "should get edit" do
    sign_in @dan
    get :edit, params: { id: @razune }
    assert_response :success
  end

  test "should update resident.js" do
    sign_in @dan
    patch :update, format: :js, params: { id: @razune, resident: { full_description: @razune.full_description, name: @razune.name, short_description: @razune.short_description, slug: @razune.slug } }
    assert_response :success
  end

end
