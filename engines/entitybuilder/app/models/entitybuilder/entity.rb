# frozen_string_literal: false

module Entitybuilder
  class Entity < ApplicationRecord
    include KeysToEntitybuilder

    PRIVACY_OPTIONS = ['Private', 'Affiliates', 'Residents']
    NULL_ATTRS = %w( )

    scope :short, -> { select('id, type, resident_id, name, short_description, core_rules, privacy, sheet_privacy') }
    scope :order_name, -> { order(:name) }

    has_one :campaign_join, :dependent => :destroy
    has_one :campaign,
            :through => :campaign_join,
            :source => :campaign,
            :class_name => "Campaignmanager::Campaign"

    has_one :district,
            -> { select('worldbuilder_districts.id, worldbuilder_districts.name, worldbuilder_districts.slug') },
            :through => :campaign,
            :class_name => "Worldbuilder::District"

    has_one :gallery_image_join,
            :as => :imageable,
            :class_name => "Gallery::ImageJoin",
            :dependent => :destroy

    has_one :gallery_image,
            :through => :gallery_image_join,
            :source => :image,
            :class_name => "Gallery::Image"

    has_many :descriptors, -> { order(:sort_order) }, :dependent => :destroy
    has_many :ability_scores, -> { order(:sort_order) }, :dependent => :destroy
    has_many :movements, -> { order(:sort_order) }, :dependent => :destroy
    has_many :class_levels, -> { order(:sort_order) }, :dependent => :destroy
    has_many :caster_levels, -> { order(:sort_order) }, :dependent => :destroy
    has_many :base_values, -> { order(:sort_order) }, :dependent => :destroy
    has_many :skills, -> { order(:sort_order) }, :dependent => :destroy
    has_many :trackables, -> { order(:sort_order) }, :dependent => :destroy
    has_many :attacks, -> { order(:sort_order) }, :dependent => :destroy
    has_many :defenses, -> { order(:sort_order) }, :dependent => :destroy
    has_many :saving_throws, -> { order(:sort_order) }, :dependent => :destroy
    has_many :currencies, -> { order(:sort_order) }, :dependent => :destroy

    has_many :linked_rules, -> { order(:sort_order) }, :dependent => :destroy
    has_many :rules, :through => :linked_rules, :class_name => "Rulebuilder::Rule"

    has_many :known_spells, -> { order(:sort_order) }, :dependent => :destroy
    has_many :spells, :through => :known_spells, :class_name => "Rulebuilder::Spell"
    has_many :prepared_known_spells, -> { order(:sort_order).prepared }, :class_name => "KnownSpell"
    has_many :prepared_spells, :through => :prepared_known_spells, :class_name => "Rulebuilder::Spell", :source => :spell

    has_many :inventory_items, -> { order(:sort_order) }, :dependent => :destroy
    has_many :items, :through => :inventory_items, :class_name => "Rulebuilder::Item"

    has_many :modifiers, -> { order(:item) }, :dependent => :destroy

    has_many :notables, -> { order(:sort_order) }, :as => :notableable, :dependent => :destroy
    has_many :entities, -> { select('id, type, name') }, :through => :notables, :source => :entity, :class_name => "Entitybuilder::Entity"

    has_many :eb_notables, -> { order(:sort_order) }, :class_name => "Entitybuilder::Notable", :dependent => :destroy
    has_many :sb_notables, -> { order(:sort_order) }, :class_name => "Storybuilder::Notable", :dependent => :destroy
    has_many :cm_notables, -> { order(:sort_order) }, :class_name => "Campaignmanager::Notable", :dependent => :destroy
    has_many :ap_notables, -> { order(:sort_order) }, :class_name => "Activeplay::Notable", :dependent => :destroy

    accepts_nested_attributes_for :gallery_image_join, :allow_destroy => true
    accepts_nested_attributes_for :campaign_join, :allow_destroy => true
    accepts_nested_attributes_for :descriptors, :allow_destroy => true
    accepts_nested_attributes_for :ability_scores, :allow_destroy => true
    accepts_nested_attributes_for :movements, :allow_destroy => true
    accepts_nested_attributes_for :class_levels, :allow_destroy => true
    accepts_nested_attributes_for :caster_levels, :allow_destroy => true
    accepts_nested_attributes_for :base_values, :allow_destroy => true
    accepts_nested_attributes_for :skills, :allow_destroy => true
    accepts_nested_attributes_for :trackables, :allow_destroy => true
    accepts_nested_attributes_for :attacks, :allow_destroy => true
    accepts_nested_attributes_for :defenses, :allow_destroy => true
    accepts_nested_attributes_for :saving_throws, :allow_destroy => true
    accepts_nested_attributes_for :currencies, :allow_destroy => true

    accepts_nested_attributes_for :linked_rules, :allow_destroy => true

    accepts_nested_attributes_for :known_spells, :allow_destroy => true
    accepts_nested_attributes_for :inventory_items, :allow_destroy => true

    accepts_nested_attributes_for :notables, :allow_destroy => true

    accepts_nested_attributes_for :modifiers, :allow_destroy => true

    validates :name, presence: true, length: { maximum: 64 }
    validates :core_rules, presence: true
    validates :privacy, presence: true, length: { maximum: 64 }
    validate  :valid_privacy
    validates :sheet_privacy, presence: true, length: { maximum: 64 }
    validate  :valid_sheet_privacy
    validates :short_description, length: { maximum: 255 }
    validates :full_description, length: { maximum: 12000 }
    validates :notes, length: { maximum: 12000 }
    validates :publisher, length: { maximum: 255 }
    validates :source, length: { maximum: 255 }
    validates_confirmation_of :name

    before_validation :set_privacy
    before_validation :nil_if_blank
    before_save :mark_for_removal

    def badge_color
      return "##{SecureRandom.hex(3)}"
    end

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

    def is_character?
      return self.type.include?"Character"
    end

    def title
      title_builder = self.class_levels.first.name.titleize if type.exclude?"Creature" and self.class_levels.any?
      title_builder = 'Commoner' if title_builder.blank? and type.include?"Character"
      return title_builder
    end

    def index_title
      title_builder = self.core_rules.titleize
      title_builder += " - #{title}" if title.present?
      return title_builder[0,50]
    end

    def profile_title
      descriptors = self.descriptors.where(name: ['Alignment', 'Size', 'Race', 'Species', 'Type', 'Classification', 'Ancestry']).pluck(:description)
      title_builder = descriptors.join(' ')
      return title_builder[0,50]
    end

    def badge_title
      return self.resident.name if self.type.include?"Character"
      #return self.profile_title if self.profile_title.present?
      return "Character" if self.type.include?"Character"
      return "Creature" if self.type.include?"Creature"
      return "NPC" if self.type.include?"Npc"
    end

    def simple_type
      return "Character" if self.type.include?"Character"
      return "Creature" if self.type.include?"Creature"
      return "NPC" if self.type.include?"Npc"
    end

    def missing_core_skills
      current_skills = skills.pluck(:name)
      skill_list = CoreRules::Entity.core_skills(core_rules).map { |m| m['name'] }
      return skill_list.reject { |d| current_skills.include?(d) }
    end

    def self.search(search)
      where("entitybuilder_entities.name ilike ?", "%#{search}%")
    end

    def self.core_rules_filter(core_rules_filter)
      where("entitybuilder_entities.core_rules ilike ?", "%#{core_rules_filter}%")
    end

    def clickable?(current_user, admin_signed_in, _type)
      return true if can_edit?(current_user, admin_signed_in, _type)
      return true if _type.include?"Stock"
      return true if _type.include?"Proprietary"
      return false
    end

    private
      def set_privacy
        self.privacy = 'Residents' if self.new_record?
        self.sheet_privacy = 'Private' if self.new_record?
      end

      def mark_for_removal
        self.gallery_image_join.mark_for_destruction if gallery_image_join && gallery_image_join.image_id.blank?
        self.campaign_join.mark_for_destruction if campaign_join && campaign_join.campaign_id.blank?
      end

      def nil_if_blank
        NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
      end

      def valid_privacy
        if privacy.present? && PRIVACY_OPTIONS.exclude?(privacy)
          errors.add(:privacy, "is not valid.")
        end
      end

      def valid_sheet_privacy
        if sheet_privacy.present? && PRIVACY_OPTIONS.exclude?(sheet_privacy)
          errors.add(:sheet_privacy, "is not valid.")
        end
      end
  end
end
