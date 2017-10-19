require 'test_helper'

module Support
  class CoreFaqsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @routes = Support::Engine.routes

      @user = users(:dan)
      @admin = admins(:dan)
      @faq = support_faqs(:one)
      @core_faq = support_core_faqs(:one)
    end

    test "should get index.html" do
      sign_in @user
      sign_in @admin
      get :index
      assert_response :success
      assert_not_nil assigns(:core_faqs)
    end

    test "should get index.js" do
      sign_in @admin
      get :index, xhr: true, format: :js
      assert_response :success
      assert_not_nil assigns(:core_faqs)
    end

    test "should get new.js" do
      sign_in @admin
      get :new, xhr: true
      assert_response :success
    end

    test "should create.js core_faq" do
      sign_in @admin
      assert_difference('CoreFaq.count') do
        post :create, format: :js, params: { core_faq: { faq_id: @faq.id, core_item: "#{@core_faq.core_item} 2", active: @core_faq.active } }
      end
      assert_response :success
      assert_equal "#{assigns(:core_faq).core_item} has been added.", flash[:notice]
    end

    test "should get edit.js" do
      sign_in @admin
      get :edit, xhr:true, params: { id: @core_faq }
      assert_response :success
    end

    test "should update.js core_faq" do
      sign_in @admin
      patch :update, format: :js, params: { id: @core_faq, core_faq: { faq_id: @faq.id, core_item: @core_faq.core_item, active: @core_faq.active } }
      assert_response :success
      assert_equal "#{@core_faq.core_item} has been updated.", flash[:notice]
    end

    test "should destroy core_faq js" do
      sign_in @admin
      assert_difference('CoreFaq.count', -1) do
        delete :destroy, format: :js, params: { id: @core_faq }
      end
      assert_response :success
      assert_equal "#{@core_faq.core_item} has been removed.", flash[:notice]
    end
  end
end
