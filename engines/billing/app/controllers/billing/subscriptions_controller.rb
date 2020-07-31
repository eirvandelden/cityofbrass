# frozen_string_literal: false

require_dependency "billing/application_controller"

module Billing
  class SubscriptionsController < ApplicationController
    before_action :authenticate_user!

    before_action :set_subscription, except: [:index, :new, :create]
    before_action :can_show,           only: [:show]
    before_action :can_edit,         except: [:index, :show, :new, :create]
    # before_action :set_plans,          only: [:index, :show, :new, :create, :edit, :update]

    # GET /subscriptions
    # GET /subscriptions.json
    def index
      respond_to do |format|
        if current_user.subscription
          format.html { redirect_to billing.subscription_path(current_user.subscription) }
        else
          format.html
          format.json
          format.js
        end
      end
    end

    # GET /subscriptions/1
    # GET /subscriptions/1.json
    def show
      customer = @subscription.user.stripe_customer
      @stripe_subscription = @subscription.stripe_subscription(customer)
      @stripe_source = @subscription.stripe_source(customer)
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /subscriptions/1
    # GET /subscriptions/1.json
    def invoices
      @invoices = @subscription.stripe_invoices(@subscription.user.stripe_customer)
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /subscriptions/1
    # GET /subscriptions/1.json
    def invoice
      @invoice = @subscription.stripe_invoice(params[:invoice_id])
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /subscriptions/new
    def new
      @subscription = current_user.build_subscription

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end

    # GET /subscriptions/1/edit
    def edit
      respond_to do |format|
        format.html
        format.js
      end
    end

    # POST /subscriptions
    # POST /subscriptions.json
    def create
      @subscription = current_user.build_subscription

      respond_to do |format|
        if @subscription.create_subscription(@subscription.user.stripe_customer, params[:stripeToken], params[:coupon])
          format.html { redirect_to @subscription, notice: 'Subscription was successfully created.' }
          format.json { render :show, status: :created, location: @subscription }
          format.js
        else
          format.html { render :new }
          format.json { render json: @subscription.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # PATCH/PUT /subscriptions/1
    # PATCH/PUT /subscriptions/1.json
    def update
      respond_to do |format|
        if @subscription.reactivate_subscription(@subscription.user.stripe_customer)
          format.html { redirect_to @subscription, notice: 'Subscription was successfully reactivated.' }
          format.json { render :show, status: :ok, location: @subscription }
          format.js   { flash.now[:notice] = 'Subscription was successfully reactivated.' }
        else
          format.html { render :edit }
          format.json { render json: @subscription.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

    # DELETE /subscriptions/1
    # DELETE /subscriptions/1.json
    def destroy
      @subscription.cancel_subscription(@subscription.user.stripe_customer)
      respond_to do |format|
        format.html { redirect_to @subscription, notice: 'Subscription was successfully canceled.' }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      # Set your secret key: remember to change this to your live secret key in production
      def set_plans
        @plans = Stripe::Plan.list.data
      end

      def set_subscription
        @subscription = Subscription.joins(:user).find_by_id(params[:id])
        if @subscription.nil?
          render template: 'errors/404', layout: 'layouts/application', status: 404
        end
      end

      def can_show
        unless @subscription.can_show?(current_user, admin_signed_in?)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      def can_edit
        unless @subscription.can_edit?(current_user, admin_signed_in?)
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

      # Only allow a trusted parameter "white list" through.
      def subscription_params
        params.require(:subscription).permit(:user_id, :coupon, :stripe_subscription_token, :status, :current_period_start, :current_period_end, :canceled_at, :cancel_at_period_end)
      end
  end
end
