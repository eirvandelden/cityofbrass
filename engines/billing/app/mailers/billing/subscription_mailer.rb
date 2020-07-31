# frozen_string_literal: false

module Billing
  class SubscriptionMailer < ApplicationMailer

    def subscription_payment_failed(user)
      @user = user
      @url = "https://#{ENV['DEFAULT_BASE_URL']}/billing"

      mail(to: @user.email, subject: "City of Brass subscription payment failed.")
    end

  end
end
