# frozen_string_literal: false

module Billing
  class Subscription < ApplicationRecord
    include KeysToBilling

    PREMIUM_SUBSCRIPTION = 'premium'

    belongs_to :user

    validates :user_id, presence: true
    validates :stripe_subscription_token, presence: true, uniqueness: true

    def create_subscription(customer, token, coupon)
      begin
        if coupon.present?
          begin
            stripe_coupon = Stripe::Coupon.retrieve(coupon.upcase)
            cid = stripe_coupon.id
            stripe_subscription = customer.subscriptions.create(:source => token, :plan => PREMIUM_SUBSCRIPTION, :coupon => cid)
          rescue Stripe::StripeError => e
            logger.error "Invalid Coupon: #{e.message}"
            errors.add :base, "Invalid Coupon"
            return false
          end
        else
          stripe_subscription = customer.subscriptions.create(:source => token, :plan => PREMIUM_SUBSCRIPTION)
        end

        self.stripe_subscription_token = stripe_subscription.id
        self.user.make_active
        return save
      rescue Stripe::StripeError => e
        logger.error "Stripe error while creating subscription: #{e.message}"
        errors.add :base, "There was a problem creating your subscription."
        return false
      rescue => e
        logger.error "Stripe error while creating subscription: #{e.message}"
        return false
      end
    end

=begin
    def update_subscription(customer, token, new_plan_id)
      return change_source(customer, token) if token.present?
      return change_plan(customer, new_plan_id) if new_plan_id.present?
      return false
    end

    def change_plan(customer, new_plan_id)
      begin
        self.plan_id = new_plan_id
        save!
        stripe_subscription = customer.subscriptions.retrieve(self.stripe_subscription_token)
        stripe_subscription.plan = self.plan.stripe_plan_token
        stripe_subscription.save
        return true
      rescue Stripe::StripeError => e
        logger.error "Stripe error while changing subscription plan: #{e.message}"
        errors.add :base, "There was a problem changing your subscription plan."
        return false
      rescue => e
        logger.error "Stripe error while changing subscription: #{e.message}"
        return false
      end
    end
=end

    def change_source(customer, token)
      begin
        source = customer.sources.create(source: token)
        source.save
        customer.default_source = source.id
        customer.save
        return true
      rescue Stripe::StripeError => e
        logger.error "Stripe error while changing subscription source: #{e.message}"
        errors.add :base, "There was a problem creating your subscription."
        return false
      rescue => e
        logger.error "Stripe error while changing subscription source: #{e.message}"
        return false
      end
    end

    def cancel_subscription(customer)
      begin
        stripe_subscription = customer.subscriptions.retrieve(self.stripe_subscription_token).delete(:at_period_end => true)
        return stripe_subscription
      rescue Stripe::StripeError => e
        logger.error "Stripe error while changing subscription plan: #{e.message}"
        errors.add :base, "There was a problem changing your subscription plan."
        return false
      rescue => e
        logger.error "Stripe error while canceling subscription: #{e.message}"
        return false
      end
    end

    def reactivate_subscription(customer)
      begin
        stripe_subscription = customer.subscriptions.retrieve(self.stripe_subscription_token)
        stripe_subscription.save
        return stripe_subscription
      rescue Stripe::StripeError => e
        logger.error "Stripe error while changing subscription plan: #{e.message}"
        errors.add :base, "There was a problem changing your subscription plan."
        return false
      rescue => e
        logger.error "Stripe error while canceling subscription: #{e.message}"
        return false
      end
    end

    def delete_subscription
      begin
        unless self.user.has_vip_status?
          self.user.status = 'canceled'
          self.user.save!
        end
        self.destroy
      rescue => e
        logger.error "Error while canceling subscription: #{e.message}"
      end
    end

    def stripe_subscription(customer)
      begin
        stripe_subscription = customer.subscriptions.retrieve(self.stripe_subscription_token)
        return stripe_subscription
      rescue Stripe::StripeError => e
        logger.error "Stripe error while retrieving subscription: #{e.message}"
        errors.add :base, "There was a problem retrieving your subscription."
        return false
      rescue => e
        logger.error "Stripe error while retrieving subscription: #{e.message}"
        return false
      end
    end

    def stripe_source(customer)
      begin
        source = customer.sources.retrieve(customer.default_source)
        return source
      rescue Stripe::StripeError => e
        logger.error "Stripe error while retrieving subscription source: #{e.message}"
        errors.add :base, "There was a problem retrieving your subscription source."
        return false
      rescue => e
        logger.error "Stripe error while retrieving subscription source: #{e.message}"
        return false
      end
    end

    def stripe_invoices(customer)
      begin
        Stripe::Invoice.all(
          :customer => self.user.stripe_customer_token,
          :limit => 12
        )
      rescue Stripe::StripeError => e
        logger.error "Stripe error while retrieving subscription invoices: #{e.message}"
        errors.add :base, "There was a problem retrieving your subscription invoices."
        return false
      end
    end

    def stripe_invoice(invoice)
      begin
        Stripe::Invoice.retrieve(invoice)
      rescue Stripe::StripeError => e
        logger.error "Stripe error while retrieving subscription invoice: #{e.message}"
        errors.add :base, "There was a problem retrieving your subscription invoice."
        return false
      end
    end

  end
end
