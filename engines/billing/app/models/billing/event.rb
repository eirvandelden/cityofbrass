# frozen_string_literal: false

module Billing
  class Event < ApplicationRecord

    belongs_to :user

    scope :order_event_date, -> { order('event_date desc') }

    validates :stripe_event_token, presence: true, uniqueness: true

    def self.search(search)
      joins(:user).where("stripe_event_token ilike ? or users.email ilike ?", "%#{search}%", "%#{search}%")
    end

    def save_stripe_event(stripe_event, user)
      begin
        existing_event_id = Event.where(stripe_event_token: stripe_event.id).pluck(:id)
        if existing_event_id.any?
          logger.info "Stripe event #{stripe_event.id} already exists."
        else
          self.user_id = user.id
          self.stripe_event_token = stripe_event.id
          self.event_date = Time.strptime(stripe_event.created.to_s, "%s")
          self.event_type = stripe_event.type
          self.event_data = stripe_event.to_json
          self.save!
        end
      rescue => e
        logger.error "Error: #{e.message}"
      end
    end

  end
end
