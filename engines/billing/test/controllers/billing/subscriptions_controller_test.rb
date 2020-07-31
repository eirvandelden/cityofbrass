# frozen_string_literal: false

require 'test_helper'

module Billing
  class SubscriptionsControllerTest < ActionController::TestCase
    setup do
      @subscription = subscriptions(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:subscriptions)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create subscription" do
      assert_difference('Subscription.count') do
        post :create, subscription: { cancel_at_period_end: @subscription.cancel_at_period_end, canceled_at: @subscription.canceled_at, current_period_end: @subscription.current_period_end, current_period_start: @subscription.current_period_start, plan_id: @subscription.plan_id, status: @subscription.status, stripe_subscription_token: @subscription.stripe_subscription_token, user_id: @subscription.user_id }
      end

      assert_redirected_to subscription_path(assigns(:subscription))
    end

    test "should show subscription" do
      get :show, id: @subscription
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @subscription
      assert_response :success
    end

    test "should update subscription" do
      patch :update, id: @subscription, subscription: { cancel_at_period_end: @subscription.cancel_at_period_end, canceled_at: @subscription.canceled_at, current_period_end: @subscription.current_period_end, current_period_start: @subscription.current_period_start, plan_id: @subscription.plan_id, status: @subscription.status, stripe_subscription_token: @subscription.stripe_subscription_token, user_id: @subscription.user_id }
      assert_redirected_to subscription_path(assigns(:subscription))
    end

    test "should destroy subscription" do
      assert_difference('Subscription.count', -1) do
        delete :destroy, id: @subscription
      end

      assert_redirected_to subscriptions_path
    end
  end
end
