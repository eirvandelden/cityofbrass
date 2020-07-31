# frozen_string_literal: false

module Support
  class CoreFaq < ApplicationRecord

    scope :order_core_item, -> { order(:core_item) }
    scope :active, -> { where(active: 'true') }

    belongs_to :faq

    validates :faq_id, presence: true
    validates :core_item, presence: true, uniqueness: true

  end
end
