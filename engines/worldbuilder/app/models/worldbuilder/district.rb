module Worldbuilder
  class District < ApplicationRecord
    include ReservedNames
    include KeysToWorldbuilder

    PRIVACY_OPTIONS_FREE = ['Private']
    PRIVACY_OPTIONS = ['Private', 'Friends', 'Residents', 'Public']

    scope :short, -> { select('worldbuilder_districts.id, resident_id, worldbuilder_districts.name, worldbuilder_districts.slug, worldbuilder_districts.short_description, worldbuilder_districts.privacy, worldbuilder_districts.updated_at, worldbuilder_districts.page_label') }
    scope :pick_list, -> { select('worldbuilder_districts.id, worldbuilder_districts.name, worldbuilder_districts.slug') }
    scope :order_name, -> { order(:name) }
    scope :order_updated_at, -> { order('updated_at desc') }

  	belongs_to :resident, -> { select('residents.id, residents.user_id, residents.name, residents.slug') }

    has_one :user,
            -> { select('users.id, email, status').where(status: User::ACTIVE_STATUS) },
            :through => :resident,
            :source => :user,
            :class_name => "User"

    has_many :features, -> { order(:sort_order) }, :as => :featureable, :dependent => :destroy
    has_many :sections, -> { order(:sort_order) }, :as => :sectionable, :dependent => :destroy
    has_many :menu_items, -> { order(:sort_order) }, :as => :menu_itemable, :dependent => :destroy
    has_one  :menu_item_join, :as => :menu_item_joinable, dependent: :destroy
    has_many :contributors, :dependent => :destroy

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
    accepts_nested_attributes_for :menu_items, :allow_destroy => true
    accepts_nested_attributes_for :menu_item_join, :allow_destroy => true
    accepts_nested_attributes_for :gallery_image_join, :allow_destroy => true

    validates :resident_id, presence: true
    validates :name, presence: true, length: { maximum: 64 }, uniqueness: { case_sensitive: false }
    validate  :name_not_reserved
    validates :slug, presence: { :message => "" }, length: { maximum: 128 }, uniqueness: { case_sensitive: false }
    validates :page_label, length: { maximum: 255 }
    validates :privacy, presence: true
    validate  :valid_privacy
    validates :short_description, length: { maximum: 255 }
    validates :full_description, length: { maximum: 12000 }
    validates_confirmation_of :name

    before_validation :make_slug
    before_save :mark_for_removal
    after_initialize :default_values

    def is_owner?(current_user)
      return true if current_user == self.user
      return false
    end

    def self.search(search)
      where("worldbuilder_districts.name ilike ?", "%#{search}%")
    end

    private

      def default_values
        if self.new_record?
          self.short_description =  "An example game world to help you get started." if self.short_description.blank?
          self.full_description =  "
                                    <blockquote>
                                    <p>Welcome to your new World! This is your setting's home page, and the first thing people will see when they visit. Make sure it looks great. </p>
                                    </blockquote>
                                    <p>We've structured World Builder so that it groups similar things together. There are seven categories, but we've started you off with these three: </p>
                                    <ul>
                                    <li>
                                    <strong>Atlas Entries</strong> are intended to be used for actual places in your world: galaxies, planets, cities, dungeons, taverns, etc. </li>
                                    <li>
                                    <strong>Inhabitants</strong> are meant to catalog the living creatures of your world: races such as elves, dwarves, or humans; animals; or even specific people. </li>
                                    <li>
                                    <strong>Lore Records</strong> are intended to tell the story of your world.</li>
                                    </ul>
                                    <p>When you're ready, you can also delve into these categories: </p>
                                    <ul>
                                    <li>
                                    <strong>Religions </strong>are meant to capture the faiths in your world. </li>
                                    <li>
                                    <strong>Deities</strong> work hand-in-hand with Religions and are where you define the actual gods. </li>
                                    <li>
                                    <strong>Planes</strong> function just like Atlas Records, but are intended for places other than the mortal realm. </li>
                                    <li>
                                    <strong>House Rules</strong>, finally, are where you can capture game rules specific to your setting. </li>
                                    </ul>
                                    <p>You can use the different record types and pages any way you want, of course, but this tells you what we were thinking when we set it all up. </p>
                                    " if self.full_description.blank?
        end
      end

      def make_slug
        self.slug = name.parameterize
      end

      def mark_for_removal
        self.gallery_image_join.mark_for_destruction if gallery_image_join && gallery_image_join.image_id.blank?
        self.menu_item_join.mark_for_destruction if menu_item_join && menu_item_join.menu_item_id.blank?
      end

      def valid_privacy
        if privacy.present? && PRIVACY_OPTIONS.exclude?(privacy)
          errors.add(:privacy, "is not valid.")
        end
      end

  end
end
