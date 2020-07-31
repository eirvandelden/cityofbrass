# frozen_string_literal: false

require 'test_helper'

module Support
  class CoreFaqsControllerTest < ActionController::TestCase
    setup do
      @core_faq = core_faqs(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:core_faqs)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create core_faq" do
      assert_difference('CoreFaq.count') do
        post :create, core_faq: { active: @core_faq.active, faq_id: @core_faq.faq_id, page_title: @core_faq.page_title }
      end

      assert_redirected_to core_faq_path(assigns(:core_faq))
    end

    test "should show core_faq" do
      get :show, id: @core_faq
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @core_faq
      assert_response :success
    end

    test "should update core_faq" do
      patch :update, id: @core_faq, core_faq: { active: @core_faq.active, faq_id: @core_faq.faq_id, page_title: @core_faq.page_title }
      assert_redirected_to core_faq_path(assigns(:core_faq))
    end

    test "should destroy core_faq" do
      assert_difference('CoreFaq.count', -1) do
        delete :destroy, id: @core_faq
      end

      assert_redirected_to core_faqs_path
    end
  end
end
