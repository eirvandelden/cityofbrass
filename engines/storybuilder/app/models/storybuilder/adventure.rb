# frozen_string_literal: false

module Storybuilder
  class Adventure < ApplicationRecord
    include KeysToStorybuilder

    PRIVACY_OPTIONS_FREE = ['Private']
    PRIVACY_OPTIONS = ['Private', 'Affiliates', 'Residents']
    NULL_ATTRS = %w( parent_id )

    scope :short, -> { select('id, type, resident_id, name, page_label, short_description, core_rules') }
    scope :pick_list, -> { select('id, name, type') }
    scope :order_name, -> { order(:name) }
    scope :stock_active, -> { where("storybuilder_adventures.privacy = ?", "Residents") }

    belongs_to :resident, -> { select('residents.id, residents.user_id, residents.name, residents.slug') }

    belongs_to :parent, :class_name => "Adventure"
    has_many :children, :class_name => "Adventure", :foreign_key => "parent_id"

    has_many :features, -> { order(:sort_order) }, :as => :featureable, :dependent => :destroy
    has_many :sections, -> { order(:sort_order) }, :as => :sectionable, :dependent => :destroy
    has_many :notables, -> { order(:sort_order) }, :as => :notableable, :dependent => :destroy
    has_many :entities, -> { select('id, type, name') }, :through => :notables, :source => :entity, :class_name => "Entitybuilder::Entity"

    has_many :menu_items, -> { order(:sort_order) }, :as => :menu_itemable, :dependent => :destroy
    has_one  :menu_item_join, :as => :menu_item_joinable, dependent: :destroy

    has_one :gallery_image_join,
            :as => :imageable,
            :class_name => "Gallery::ImageJoin",
            :dependent => :destroy

    has_one :gallery_image,
            :through => :gallery_image_join,
            :source => :image,
            :class_name => "Gallery::Image"

    has_many :pages, dependent: :destroy

    accepts_nested_attributes_for :features, :allow_destroy => true
    accepts_nested_attributes_for :sections, :allow_destroy => true
    accepts_nested_attributes_for :notables, :allow_destroy => true
    accepts_nested_attributes_for :menu_items, :allow_destroy => true
    accepts_nested_attributes_for :menu_item_join, :allow_destroy => true
    accepts_nested_attributes_for :gallery_image_join, :allow_destroy => true

    validates :name, uniqueness: { scope: [:resident_id, :core_rules] }, presence: true, length: { maximum: 64 }
    validates :slug, uniqueness: { scope: [:resident_id, :core_rules] }, presence: true, length: { maximum: 128 }
    validates :page_label, length: { maximum: 255 }
    validates :privacy, presence: true
    validate  :valid_privacy
    validates :short_description, length: { maximum: 255 }
    validates :full_description, length: { maximum: 12000 }
    validates_confirmation_of :name

    before_validation :make_slug
    before_validation :nil_if_blank
    before_save :mark_for_removal

    def self.search(search)
      where("storybuilder_adventures.name ilike ?", "%#{search}%")
    end

    def self.core_rules_filter(core_rules)
      where("storybuilder_adventures.core_rules ilike ?", "%#{core_rules}%")
    end

    def self.simple_type
      return self.type.demodulize
    end

    private
      def make_slug
        self.slug = self.name.parameterize
      end

      def nil_if_blank
        NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
      end

      def mark_for_removal
        self.menu_item_join.mark_for_destruction if menu_item_join && menu_item_join.menu_item_id.blank?
        self.gallery_image_join.mark_for_destruction if gallery_image_join && gallery_image_join.image_id.blank?
      end

      def valid_privacy
        if privacy.present? && PRIVACY_OPTIONS.exclude?(privacy)
          errors.add(:privacy, "is not valid.")
        end
      end

  end
end
