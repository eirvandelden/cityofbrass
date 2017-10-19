require_dependency "billing/application_controller"

module Billing
  class WebhookController < ApplicationController
    # You need this line or you'll get CSRF/token errors from Rails (because this is a post)
    # skip_before_action :verify_authenticity_token

    protect_from_forgery except: :stripe

    before_action :verify_authenticity_token

    CUSTOMER_CREATED              = "customer.deleted"
    CUSTOMER_UPDATED              = "customer.updated"
    CUSTOMER_DELETED              = "customer.created"
    CUSTOMER_SUBSCRIPTION_CREATED = "customer.subscription.created"
    CUSTOMER_SUBSCRIPTION_UPDATED = "customer.subscription.updated"
    CUSTOMER_SUBSCRIPTION_DELETED = "customer.subscription.deleted"
    INVOICE_PAMENT_SUCCEEDED      = "invoice.payment_succeeded"
    INVOICE_PAYMENT_FAILED        = "invoice.payment_failed"

    CUSTOMER_ARRAY = [CUSTOMER_CREATED, CUSTOMER_UPDATED, CUSTOMER_DELETED]

    def stripe
      begin
        logger.info "Received stripe event with ID: #{params[:id]}"

        # Retrieving the stripe_event from the Stripe API guarantees its authenticity
        stripe_event = Stripe::Event.retrieve(params[:id])

        if CUSTOMER_ARRAY.include?stripe_event.type
          customer = stripe_event.data.object.id
        else
          customer = stripe_event.data.object.customer
        end

        user = User.includes(:subscription).find_by_stripe_customer_token(customer)

        # Lets save the event for historical purposes
        event = Event.new
        event.save_stripe_event(stripe_event, user)

        case stripe_event.type
          when CUSTOMER_CREATED
            logger.info "Event Received: #{user.email} created."

          when CUSTOMER_UPDATED
            logger.info "Event Received: #{user.email} updated."

          when CUSTOMER_DELETED
            logger.info "Event Received: #{user.email} deleted."

          when CUSTOMER_SUBSCRIPTION_CREATED
            logger.info "Event Received: #{user.email} subscription #{stripe_event.data.object.id} created."

          when CUSTOMER_SUBSCRIPTION_UPDATED
            logger.info "Event Received: #{user.email} subscription #{stripe_event.data.object.id} updated."

          when CUSTOMER_SUBSCRIPTION_DELETED
            logger.info "Event Received: #{user.email} subscription #{stripe_event.data.object.id} deleted."
            if user.subscription.present?
              user.subscription.delete_subscription
            end

          when INVOICE_PAMENT_SUCCEEDED
            logger.info "Event Received: #{user.email} payment succeeded."
            user.make_active

          when INVOICE_PAYMENT_FAILED
            SubscriptionMailer.subscription_payment_failed(user).deliver_later
            logger.info "Event Received: #{user.email} payment failed."

          else
            logger.info "Event received. Did not handle this stripe_event: #{stripe_event.type}"
        end

        head :ok
      rescue => e
        logger.error "Stripe error: #{e.message}"
        head :status =>500
      end
    end

    private
      def verify_authenticity_token
        unless params[:token] == ENV["STRIPE_WEBHOOK_TOKEN"]
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end

  end
end
