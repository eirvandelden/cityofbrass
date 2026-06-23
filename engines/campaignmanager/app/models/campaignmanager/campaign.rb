module Campaignmanager
  class Campaign < ApplicationRecord
    include ReservedNames
    include KeysToCampaignmanager

    has_rich_text :full_description

    PRIVACY_OPTIONS = [ 'Private', 'Friends', 'Residents', 'Public' ]
    PRIVACY_OPTIONS_FREE = PRIVACY_OPTIONS
    NULL_ATTRS = %w[ district_id ]

    scope :short, -> { select('campaignmanager_campaigns.id, campaignmanager_campaigns.resident_id, campaignmanager_campaigns.core_rules, campaignmanager_campaigns.district_id, campaignmanager_campaigns.name, campaignmanager_campaigns.privacy, campaignmanager_campaigns.short_description, campaignmanager_campaigns.page_label, campaignmanager_campaigns.updated_at') }
    scope :order_name, -> { order(:name) }
    scope :order_updated_at, -> { order(Arel.sql('campaignmanager_campaigns.updated_at desc')) }

    belongs_to :resident, -> { select('residents.id, residents.user_id, residents.name, residents.slug') }

    has_one :user,
            -> { select('users.id, email, status').where(status: User::ACTIVE_STATUS) },
            through: :resident,
            source: :user,
            class_name: "User"

    belongs_to :district,
            -> { select('worldbuilder_districts.id, worldbuilder_districts.resident_id, worldbuilder_districts.name, worldbuilder_districts.slug, worldbuilder_districts.privacy') },
            class_name: "Worldbuilder::District"

    has_many :features, -> { order(:sort_order) }, as: :featureable, dependent: :destroy
    has_many :sections, -> { order(:sort_order) }, as: :sectionable, dependent: :destroy
    has_many :notables, -> { order(:sort_order) }, as: :notableable, dependent: :destroy
    has_many :menu_items, -> { order(:sort_order) }, as: :menu_itemable, class_name: "Storybuilder::MenuItem", dependent: :destroy
    has_many :entities, -> { select('entitybuilder_entities.id, entitybuilder_entities.type, entitybuilder_entities.resident_id, entitybuilder_entities.privacy, entitybuilder_entities.sheet_privacy, entitybuilder_entities.name, entitybuilder_entities.core_rules, entitybuilder_entities.short_description') }, through: :notables, source: :entity, class_name: "Entitybuilder::Entity"

    has_many :players,
             dependent: :destroy

    has_many :player_residents,
             -> { select('residents.id', 'residents.name', 'residents.slug').order(:name) },
             through: :players,
             class_name: "Resident",
             source: :affiliate

    has_many :entity_joins,
             class_name: "Entitybuilder::CampaignJoin",
             dependent: :destroy

    has_many :campaign_adventure_joins,
             class_name: "Campaignmanager::CampaignAdventureJoin",
             dependent: :destroy

    has_many :adventures,
             -> { select('storybuilder_adventures.id, storybuilder_adventures.resident_id, storybuilder_adventures.name, storybuilder_adventures.slug, storybuilder_adventures.type, storybuilder_adventures.privacy') },
             through: :campaign_adventure_joins,
             class_name: "Storybuilder::Adventure"

    has_one :active_adventure_join,
            -> { where(active: true) },
            class_name: "Campaignmanager::CampaignAdventureJoin"

    has_one :active_adventure,
            through: :active_adventure_join,
            source: :adventure,
            class_name: "Storybuilder::Adventure"

    has_many :characters,
             -> { select('entitybuilder_entities.id, entitybuilder_entities.type, entitybuilder_entities.resident_id, entitybuilder_entities.privacy, entitybuilder_entities.sheet_privacy, entitybuilder_entities.name, entitybuilder_entities.core_rules, entitybuilder_entities.short_description').order(:name) },
             through: :entity_joins,
             class_name: "Entitybuilder::ResidentCharacter",
             source: :entity

    has_many :class_levels,
             through: :characters,
             class_name: "Entitybuilder::ClassLevel"

    has_one :gallery_image_join,
            as: :imageable,
            class_name: "Gallery::ImageJoin",
            dependent: :destroy

    has_one :gallery_image,
            through: :gallery_image_join,
            source: :image,
            class_name: "Gallery::Image"

    has_one :activeplay,
            class_name: "Activeplay::VirtualTable",
            dependent: :destroy

    has_many :pages, dependent: :destroy
    has_many :adventure_logs, -> { order(Arel.sql('COALESCE(page_date, created_at) DESC')) }, dependent: :destroy
    has_many :house_rules, -> { order(:name) }, dependent: :destroy
    has_many :game_master_notes, -> { order(:name) }, dependent: :destroy

    accepts_nested_attributes_for :features, allow_destroy: true
    accepts_nested_attributes_for :sections, allow_destroy: true
    accepts_nested_attributes_for :notables, allow_destroy: true
    accepts_nested_attributes_for :menu_items, allow_destroy: true
    accepts_nested_attributes_for :gallery_image_join, allow_destroy: true

    validates :resident_id, presence: true
    validates :name, uniqueness: { scope: :resident_id }, presence: true, length: { maximum: 64 }
    validate  :name_not_reserved
    validates :slug, uniqueness: { scope: :resident_id }, presence: true, length: { maximum: 128 }
    validates :page_label, length: { maximum: 255 }
    validates :privacy, presence: true
    validate  :valid_privacy
    validates :short_description, length: { maximum: 255 }

    before_validation :make_slug
    before_validation :nil_if_blank
    before_save :mark_for_removal

    def self.search(search)
      where("campaignmanager_campaigns.name like ?", "%#{search}%")
    end

    def active_adventure_id
      active_adventure_join&.adventure_id
    end

    def active_adventure_id=(adventure_id)
      campaign_adventure_joins.update_all(active: false)
      return if adventure_id.blank?

      campaign_adventure_joins.where(adventure_id: adventure_id).update_all(active: true)
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

      def valid_privacy
        if privacy.present? && PRIVACY_OPTIONS.exclude?(privacy)
          errors.add(:privacy, "is not valid.")
        end
      end
  end
end
