require_relative "../../../../../app/models/concerns/json_array_columns"

module Storybuilder
  class Page < ApplicationRecord
    include KeysToStorybuilder
    include JsonArrayColumns

    NULL_ATTRS = %w[ parent_id ]

    scope :short, -> {
      select(:id, :adventure_id, :parent_id, :name, :short_description, :page_label, :privacy)
    }
    scope :block, -> { select(:id, :adventure_id, :parent_id, :name, :privacy) }
    scope :order_name, -> { order(:name) }

    json_array_column :tags

    scope :any_tags, ->(tags) { json_array_contains_any(:tags, tags) }
    scope :all_tags, ->(tags) { json_array_contains_all(:tags, tags) }

    belongs_to :adventure, -> { select('storybuilder_adventures.id, storybuilder_adventures.name, storybuilder_adventures.resident_id, storybuilder_adventures.type, storybuilder_adventures.core_rules') }, touch: true
    has_one :resident, -> { select('residents.id, residents.user_id, residents.name, residents.slug') }, through: :adventure

    has_one :user,
            -> { select('users.id, email, status').where(status: User::ACTIVE_STATUS) },
            through: :resident,
            source: :user,
            class_name: "User"

    belongs_to :parent, class_name: "Page"

    has_many :children, class_name: "Page", foreign_key: "parent_id"
    has_many :features, -> { order(:sort_order) }, as: :featureable, dependent: :destroy
    has_many :sections, -> { order(:sort_order) }, as: :sectionable, dependent: :destroy
    has_many :notables, -> { order(:sort_order) }, as: :notableable, dependent: :destroy
    has_many :entities, -> { select('id, type, name') }, through: :notables, source: :entity, class_name: "Entitybuilder::Entity"
    has_one  :menu_item_join, as: :menu_item_joinable, dependent: :destroy

    has_one :gallery_image_join,
            as: :imageable,
            class_name: "Gallery::ImageJoin",
            dependent: :destroy

    has_one :gallery_image,
            through: :gallery_image_join,
            source: :image,
            class_name: "Gallery::Image"

    accepts_nested_attributes_for :features, allow_destroy: true
    accepts_nested_attributes_for :sections, allow_destroy: true
    accepts_nested_attributes_for :notables, allow_destroy: true
    accepts_nested_attributes_for :gallery_image_join, allow_destroy: true
    accepts_nested_attributes_for :menu_item_join, allow_destroy: true

    validates :adventure_id, presence: true
    validates :name, uniqueness: { scope: [ :adventure_id ] }, presence: true, length: { maximum: 64 }
    validates :slug, uniqueness: { scope: [ :adventure_id ] }, presence: true, length: { maximum: 128 }
    validates :page_label, length: { maximum: 255 }
    validates :privacy, presence: true
    validate  :valid_privacy
    validates :short_description, length: { maximum: 255 }

    before_validation :make_slug
    before_validation :nil_if_blank
    before_save :mark_for_removal

    def tag_list
      Array(tags).join(', ')
    end

    def tag_list=(names)
      self.tags = names.split(',').map do |n|
        n = n.parameterize.tr('-', ' ').strip
      end.uniq.sort
    end

    def self.search(search)
      where("storybuilder_pages.name like ?", "%#{search}%")
    end

    private

      # disable the type column.  we will delete later
      def self.inheritance_column
        nil
      end

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
        if privacy.present? && Storybuilder::Adventure::PRIVACY_OPTIONS.exclude?(privacy)
          errors.add(:privacy, "is not valid.")
        end
      end
  end
end
