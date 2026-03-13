module Rulebuilder
  class Item < ApplicationRecord
    include KeysToRulebuilder

    scope :order_name, -> { order(:name) }
    scope :short, -> { select('id, type, resident_id, name, core_rules, short_description') }
    scope :basic, -> { select('id, type, resident_id, name, core_rules') }

    belongs_to :parent, :class_name => "Item"

    has_many :children, -> { order(:name) }, :class_name => "Item", :foreign_key => "parent_id"
    has_many :inventory_items, :class_name => "Entitybuilder::InventoryItem", :dependent => :destroy

    has_one :gallery_image_join,
            :as => :imageable,
            :class_name => "Gallery::ImageJoin",
            :dependent => :destroy

    has_one :gallery_image,
            :through => :gallery_image_join,
            :source => :image,
            :class_name => "Gallery::Image"

    accepts_nested_attributes_for :gallery_image_join, :allow_destroy => true

    validates :name, presence: true, length: { maximum: 64 }
    validates :core_rules, presence: true
    validates :short_description, length: { maximum: 255 }
    validates :full_description, length: { maximum: 12000 }
    validates :category, length: { maximum: 64 }
    validates :publisher, length: { maximum: 255 }
    validates :source, length: { maximum: 255 }
    validates_confirmation_of :name

    before_save :mark_for_removal

    def tag_list
      tags.join(', ')
    end

    def tag_list=(names)
      self.tags = names.split(',').map do |n|
        n = n.parameterize.gsub('-', ' ').strip
      end
      self.tags.uniq!
      self.tags.sort!
    end

    def self.search(search)
      where("rulebuilder_items.name ilike ?", "%#{search}%")
    end

    def self.core_rules_filter(core_rules_filter)
      where("rulebuilder_items.core_rules ilike ?", "%#{core_rules_filter}%")
    end

    private
      def mark_for_removal
        self.gallery_image_join.mark_for_destruction if gallery_image_join && gallery_image_join.image_id.blank?
      end

  end
end
