require_relative "../../../../../app/models/concerns/json_array_columns"

module Rulebuilder
  class Item < ApplicationRecord
    include KeysToRulebuilder
    include JsonArrayColumns

    PRIVACY_OPTIONS = [ 'Private', 'Friends', 'Residents', 'Public' ]
    PRIVACY_OPTIONS_FREE = PRIVACY_OPTIONS

    scope :order_name, -> { order(:name) }
    scope :short, -> { select('id, type, resident_id, name, core_rules, short_description') }
    scope :basic, -> { select('id, type, resident_id, name, core_rules') }

    json_array_column :tags

    belongs_to :parent, class_name: "Item"

    has_many :children, -> { order(:name) }, class_name: "Item", foreign_key: "parent_id"
    has_many :inventory_items, class_name: "Entitybuilder::InventoryItem", dependent: :destroy

    has_one :gallery_image_join,
            as: :imageable,
            class_name: "Gallery::ImageJoin",
            dependent: :destroy

    has_one :gallery_image,
            through: :gallery_image_join,
            source: :image,
            class_name: "Gallery::Image"

    accepts_nested_attributes_for :gallery_image_join, allow_destroy: true

    validates :name, presence: true, length: { maximum: 64 }
    validates :core_rules, presence: true
    validates :short_description, length: { maximum: 255 }
    validates :full_description, length: { maximum: 12000 }
    validates :category, length: { maximum: 64 }
    validates :publisher, length: { maximum: 255 }
    validates :source, length: { maximum: 255 }
    validates_confirmation_of :name
    validates :privacy, presence: true
    validate  :valid_privacy

    before_save :mark_for_removal
    before_validation :set_privacy, on: :create

    def tag_list
      Array(tags).join(', ')
    end

    def tag_list=(names)
      self.tags = names.split(',').map do |n|
        n = n.parameterize.tr('-', ' ').strip
      end.uniq.sort
    end

    def self.search(search)
      where("rulebuilder_items.name like ?", "%#{search}%")
    end

    def self.core_rules_filter(core_rules_filter)
      where("rulebuilder_items.core_rules like ?", "%#{core_rules_filter}%")
    end

    private
      def mark_for_removal
        self.gallery_image_join.mark_for_destruction if gallery_image_join && gallery_image_join.image_id.blank?
      end

      def set_privacy
        self.privacy ||= 'Private'
      end

      def valid_privacy
        if privacy.present? && PRIVACY_OPTIONS.exclude?(privacy)
          errors.add(:privacy, :invalid_privacy)
        end
      end
  end
end
