# frozen_string_literal: false

require 'test_helper'

module Support
  class FaqsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Support::Engine.routes

      @user = users(:dan)
      @admin = admins(:dan)
      @faq = support_faqs(:one)
    end

    test "should get index" do
      sign_in @user
      get :index
      assert_response :success
      assert_not_nil assigns(:faqs)
    end

    test "should not get new" do
      sign_in @user
      get :new
      assert_response 302
    end

    test "should get new" do
      sign_in @user
      sign_in @admin
      get :new
      assert_response :success
    end

    test "should not create faq" do
      sign_in @user
      assert_no_difference('Faq.count') do
        post :create, params: { faq: { topic: "test topic", question: "did this work?", answer: "no", active: "f" } }
      end

      assert_response 302
      assert_nil flash[:notice]
    end

    test "should create faq" do
      sign_in @user
      sign_in @admin
      assert_difference('Faq.count') do
        post :create, params: { faq: { topic: "test topic", question: "did this work?", answer: "no", active: "f" } }
      end

      assert_redirected_to assigns(:faq)
      assert_equal "Faq was successfully created", flash[:notice]
    end

    test "should show faq" do
      get :show, params: { id: @faq }
      assert_response :success
      assert_not_nil assigns(:faq)
    end

    test "should not get edit" do
      sign_in @user
      get :edit, params: { id: @faq }
      assert_response 302
    end

    test "should get edit" do
      sign_in @user
      sign_in @admin
      get :edit, params: { id: @faq }
      assert_response :success
    end

    test "should not destroy faq" do
      sign_in @user
      assert_no_difference('Faq.count') do
        delete :destroy, params: { id: @faq }
      end

      assert_response 302
    end

    test "should destroy faq" do
      sign_in @admin
      assert_difference('Faq.count', -1) do
        delete :destroy, params: { id: @faq }
      end

      assert_redirected_to :controller => 'support/faqs', :action => 'index'
    end

  end
end
