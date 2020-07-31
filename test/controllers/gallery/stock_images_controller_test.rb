# frozen_string_literal: false

require 'test_helper'

module Gallery
  class StockImagesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Gallery::Engine.routes
      @user = users(:dan)
      @admin = admins(:dan)

      @image = gallery_images(:stock_one)
    end

    test "should not get index" do
      get :index
      assert_response 302
    end

    test "should get index" do
      sign_in @user
      get :index
      assert_response :success
      assert_not_nil assigns(:images)
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

    test "should not create image" do
      assert_difference('Image.count', 0) do
        post :create, params: { stock_image: { name: @image.name } }
      end
      assert_response 302
    end

    #test "should create image" do
    #  sign_in @user
    #  assert_difference('Image.count') do
    #    post :create, stock_image: { name: @image.name }
    #  end
    #  assert_redirected_to edit_stock_image_path(assigns(:image))
    #end

    test "should not show image" do
      get :show, params: { id: @image }
      assert_response 302
    end

    test "should show image" do
      sign_in @user
      get :show, params: { id: @image }
      assert_response :success
    end

    test "should not pkr.js image" do
      get :pkr, xhr: true, format: :js
      assert_response 401
    end

    test "should pkr.js image" do
      sign_in @user
      get :pkr, xhr: true, format: :js
      assert_response :success
    end

    test "should not get edit" do
      sign_in @user
      get :edit, params: { id: @image }
      assert_response 403
    end

    test "should get edit" do
      sign_in @user
      sign_in @admin
      get :edit, params: { id: @image }
      assert_response :success
    end

    test "should not update image" do
      sign_in @user
      patch :update, params: { id: @image, stock_image: { name: @image.name } }
      assert_response 403
    end

    test "should update image" do
      sign_in @user
      sign_in @admin
      patch :update, params: { id: @image, stock_image: { name: @image.name } }
      #assert_redirected_to edit_stock_image_path(assigns(:image))
    end

    test "should not destroy image" do
      sign_in @user
      assert_difference('Image.count', 0) do
        delete :destroy, params: { id: @image, stock_image: { name: @image.name } }
      end
      assert_response 403
    end

    test "should destroy image" do
      sign_in @user
      sign_in @admin
      assert_difference('Image.count', -1) do
        delete :destroy, params: { id: @image, stock_image: { name: @image.name } }
      end
      assert_redirected_to stock_images_path
    end
  end
end
