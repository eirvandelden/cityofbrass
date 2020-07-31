# frozen_string_literal: false

module Campaignmanager
  class Feature < ApplicationRecord

    default_scope { order(:sort_order) }
    scope :order_sort_order, -> { order(:sort_order) }

    belongs_to :featureable, :polymorphic => true

    validates :featureable_type, presence: true, allow_nil: false
    validates :feature_type, presence: true
    validates :feature_label, length: { maximum: 64 }, presence: true
    validates :feature_text, length: { maximum: 1000 }
    validates :search_tags, length: { maximum: 255 }, :presence => true, :if => "'tag'.include?feature_type"
    validates :record_type, length: { maximum: 255 }, :presence => true, :if => "'tag'.include?feature_type"

    before_save :tag_to_lower

    private
      def tag_to_lower
        self.search_tags = self.search_tags.parameterize.gsub('-', ' ').strip if self.search_tags?
      end

  end
end
