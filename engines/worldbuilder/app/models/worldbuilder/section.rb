# frozen_string_literal: false

module Worldbuilder
  class Section < ApplicationRecord
    OPTIONS = ['text', 'child', 'tag']

    scope :order_sort_order, -> { order(:sort_order) }

    belongs_to :sectionable, :polymorphic => true

    validates :sectionable_type, presence: true, allow_nil: false
    validates :section_type, presence: true
    validates :section_style, presence: true
    validates :header, length: { maximum: 64 }
    validates :content, length: { maximum: 12000 }
    validates :search_tags, length: { maximum: 255 }, :presence => true, :if => "'tag'.include?section_type"
    validates :record_type, length: { maximum: 255 }, :presence => true, :if => "'tag'.include?section_type"

    before_save :tag_to_lower

    private
      def tag_to_lower
        self.search_tags = self.search_tags.parameterize.gsub('-', ' ').strip if self.search_tags?
      end

  end
end
