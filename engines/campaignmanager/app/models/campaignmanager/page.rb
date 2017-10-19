module Campaignmanager
  class Page < ApplicationRecord
    include KeysToCampaignmanager

    NULL_ATTRS = %w( parent_id )

    scope :short, -> { select('campaignmanager_pages.id, campaignmanager_pages.campaign_id, campaignmanager_pages.parent_id, campaignmanager_pages.name, campaignmanager_pages.type, campaignmanager_pages.privacy, campaignmanager_pages.short_description, campaignmanager_pages.page_label') }
    scope :block, -> { select('campaignmanager_pages.id, campaignmanager_pages.campaign_id, campaignmanager_pages.parent_id, campaignmanager_pages.name, campaignmanager_pages.type, campaignmanager_pages.privacy') }
    scope :order_name, -> { order(:name) }

    belongs_to :campaign, -> { select('campaignmanager_campaigns.id, campaignmanager_campaigns.name, campaignmanager_campaigns.resident_id, campaignmanager_campaigns.core_rules') }, touch: true
    has_one :resident, -> { select('residents.id, residents.user_id, residents.name, residents.slug') }, :through => :campaign

    has_one :user,
            -> { select('users.id, email, status').where(status: User::ACTIVE_STATUS) },
            :through => :resident,
            :source => :user,
            :class_name => "User"

    belongs_to :parent, :class_name => "Page"

    has_many :children, -> { order(:name) }, :class_name => "Page", :foreign_key => "parent_id"
    has_many :features, -> { order(:sort_order) }, :as => :featureable, :dependent => :destroy
    has_many :sections, -> { order(:sort_order) }, :as => :sectionable, :dependent => :destroy
    has_many :notables, -> { order(:sort_order) }, :as => :notableable, :dependent => :destroy
    has_many :entities, -> { select('id, type, name') }, :through => :notables, :source => :entity, :class_name => "Entitybuilder::Entity"

    has_one :gallery_image_join,
            :as => :imageable,
            :class_name => "Gallery::ImageJoin",
            :dependent => :destroy

    has_one :gallery_image,
            :through => :gallery_image_join,
            :source => :image,
            :class_name => "Gallery::Image"

    accepts_nested_attributes_for :features, :allow_destroy => true
    accepts_nested_attributes_for :sections, :allow_destroy => true
    accepts_nested_attributes_for :notables, :allow_destroy => true
    accepts_nested_attributes_for :gallery_image_join, :allow_destroy => true

    validates :campaign_id, presence: true
    validates :name, uniqueness: { scope: [:campaign_id, :type] }, presence: true, length: { maximum: 64 }
    validates :slug, uniqueness: { scope: [:campaign_id, :type] }, presence: true, length: { maximum: 128 }
    validates :page_label, length: { maximum: 255 }
    validates :privacy, presence: true
    validate  :valid_privacy
    validates :short_description, length: { maximum: 255 }
    validates :full_description, length: { maximum: 12000 }
    validates_confirmation_of :name

    before_validation :make_slug
    before_validation :nil_if_blank
    before_save :mark_for_removal

    def icon
      'icon-docs'
    end

    private
      def make_slug
        self.slug = self.name.parameterize
      end

      def nil_if_blank
        NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
      end

      def mark_for_removal
        self.gallery_image_join.mark_for_destruction if gallery_image_join && gallery_image_join.image_id.blank?
      end

      def assign_default_privacy
        self.privacy = 'Private'
      end

      def valid_privacy
        if privacy.present? && Campaignmanager::Campaign::PRIVACY_OPTIONS.exclude?(privacy)
          errors.add(:privacy, "is not valid.")
        end
      end

  end
end
