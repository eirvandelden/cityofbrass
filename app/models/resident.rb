class Resident < ApplicationRecord
  include ReservedNames

  scope :order_name, -> { order(:slug) }
  scope :short, -> { select('name, slug, short_description, residents.created_at') }

  belongs_to :user, -> { select('id').where(status: User::ACTIVE_STATUS) }

  has_many :districts, -> { order(:name) },  :class_name => "Worldbuilder::District"
  has_many :top_5_districts, -> { select('id, resident_id, name, slug, short_description, privacy, updated_at').order('updated_at desc').limit(5) }, :class_name => "Worldbuilder::District"
  has_many :top_5_districts_public, -> { select('id, resident_id, name, slug, short_description, privacy, updated_at').order('updated_at desc').where(privacy: ['Public', 'Residents']).limit(5) }, :class_name => "Worldbuilder::District"
  has_many :resident_adventures, :class_name => "Storybuilder::ResidentAdventure"
  has_many :top_5_adventures, -> { select('id, resident_id, name, slug, short_description, privacy, updated_at').order('updated_at desc').limit(5) }, :class_name => "Storybuilder::ResidentAdventure"
  has_many :campaigns, :class_name => "Campaignmanager::Campaign"
  has_many :top_5_campaigns, -> { select('id, resident_id, name, slug, short_description, privacy, updated_at').order('updated_at desc').limit(5) }, :class_name => "Campaignmanager::Campaign"

  has_many :entities, -> { order(:name) }, :class_name => "Entitybuilder::Entity"

  has_many :resident_characters, -> { order(:name) }, :class_name => "Entitybuilder::ResidentCharacter"
  has_many :top_5_characters, -> { select('id, resident_id, name, short_description, privacy, updated_at').order('updated_at desc').limit(5) }, :class_name => "Entitybuilder::ResidentCharacter"

  has_many :resident_creatures, -> { order(:name) }, :class_name => "Entitybuilder::ResidentCreature"
  has_many :top_5_creatures, -> { select('id, resident_id, name, short_description, privacy, updated_at').order('updated_at desc').limit(5) }, :class_name => "Entitybuilder::ResidentCreature"

  has_many :resident_npcs, -> { order(:name) }, :class_name => "Entitybuilder::ResidentNpc"
  has_many :top_5_npcs, -> { select('id, resident_id, name, short_description, privacy, updated_at').order('updated_at desc').limit(5) }, :class_name => "Entitybuilder::ResidentNpc"

  has_many :resident_items,     -> { order(:name) }, :class_name => "Rulebuilder::ResidentItem"
  has_many :resident_spells,    -> { order(:name) }, :class_name => "Rulebuilder::ResidentSpell"
  has_many :resident_rules,     -> { order(:name) }, :class_name => "Rulebuilder::ResidentRule"

  has_many :resident_images, -> { order(:name) }, :class_name => "Gallery::ResidentImage"

  has_one :gallery_image_join,
          :as => :imageable,
          :class_name => "Gallery::ImageJoin",
          dependent: :destroy

  has_one :gallery_image,
          :through => :gallery_image_join,
          :source => :image,
          :class_name => "Gallery::Image"

  accepts_nested_attributes_for :gallery_image_join, :allow_destroy => true

  has_many :affiliations

  has_many :affiliated,
           -> { where("affiliations.status = 'accepted'") },
           :class_name => "Affiliation",
           :foreign_key => "affiliate_id"

  has_many :affiliates,
           -> { select('residents.id', 'residents.name', 'residents.slug', 'residents.short_description', 'residents.created_at').joins(:user).where("affiliations.status = 'accepted'").order(:name) },
           :through => :affiliations,
           :source => :affiliate,
           :class_name => "Resident"
  has_many :top_10_affiliates,
           -> { select('residents.id', 'residents.name', 'residents.slug', 'residents.short_description', 'residents.created_at', 'users.current_sign_in_at').joins(:user).where("affiliations.status = 'accepted'").order('users.current_sign_in_at DESC').limit(10) },
           :through => :affiliations,
           :source => :affiliate,
           :class_name => "Resident"

  has_many :requested_affiliations,
           -> { select('residents.id', 'residents.name', 'residents.slug', 'residents.short_description', 'residents.created_at').joins(:user).where("affiliations.status = 'requested'").order(:name) },
           :through => :affiliations,
           :source => :affiliate,
           :class_name => "Resident"
  has_many :top_5_requested_affiliations,
           -> { select('residents.id', 'residents.name', 'residents.slug', 'residents.short_description', 'residents.created_at').joins(:user).where("affiliations.status = 'requested'").order(:name).limit(5) },
           :through => :affiliations,
           :source => :affiliate,
           :class_name => "Resident"

  has_many :pending_affiliations,
           -> { select('residents.id', 'residents.name', 'residents.slug', 'residents.short_description', 'residents.created_at').joins(:user).where("affiliations.status = 'pending'").order(:name) },
           :through => :affiliations,
           :source => :affiliate,
           :class_name => "Resident"
  has_many :top_5_pending_affiliations,
           -> { select('residents.id', 'residents.name', 'residents.slug', 'residents.short_description', 'residents.created_at').joins(:user).where("affiliations.status = 'pending'").order(:name).limit(5) },
           :through => :affiliations,
           :source => :affiliate,
           :class_name => "Resident"

  has_many :blocked_affiliations,
           -> { select('residents.id', 'residents.name', 'residents.slug', 'residents.short_description', 'residents.created_at').joins(:user).where("affiliations.status = 'blocked'").order(:name) },
           :through => :affiliations,
           :source => :affiliate

  has_many :messages_sent,
           -> { where(["messages.sender_deleted = ?", false]).order('messages.created_at DESC') },
           :class_name => 'Message',
           :foreign_key => 'sender_id'

  has_many :messages_received,
           -> { where(["messages.recipient_deleted = ?", false]).order('messages.created_at DESC') },
           :class_name => 'Message',
           :foreign_key => 'recipient_id'

  validates :user_id, presence: true, uniqueness: true
  validates :name, presence: true, length: { minimum: 2, maximum: 20 }, uniqueness: { case_sensitive: false }
  validate  :name_not_reserved
  validates :slug, presence: { :message => "" }, length: { maximum: 128 }, uniqueness: { :message => "has already been taken." }
  validates :short_description, length: { maximum: 255 }
  validates :full_description, length: { maximum: 12000 }
  validates :badges, length: { maximum: 6000 }


  before_validation :make_slug
  before_save :mark_for_removal

  def active?
    return user.status
  end

  def unread_messages?
    unread_message_count > 0 ? true : false
  end

  def unread_message_count
    messages_received.where("read_at IS NULL").count
  end

  def wb_contributions
    return Worldbuilder::Contributor.joins(:district_user, :affiliate_user).includes(:district_resident).select('id', 'district_id', 'worldbuilder_districts.id', 'worldbuilder_districts.name', 'worldbuilder_districts.slug', 'worldbuilder_districts.short_description', 'worldbuilder_districts.updated_at').where("affiliation_id IN (?)", self.affiliated.map(&:id).uniq)
  end

  def cm_pc_campaigns
    return Campaignmanager::Player.joins(:campaign_user).includes(:campaign, :campaign_resident).where("affiliation_id IN (?)", self.affiliated.map(&:id).uniq).order("campaignmanager_campaigns.name")
  end

  def campaign_list
    campaign_list = self.campaigns.to_a
    self.cm_pc_campaigns.each do |player|
      campaign_list << player.campaign
    end

    return campaign_list.sort_by! { |dl| dl.name.downcase }
  end

  def adventure_list(core_rules)
    resident_list = self.resident_adventures.core_rules_filter(core_rules).pick_list.order(:name)
    stock_list = Storybuilder::StockAdventure.core_rules_filter(core_rules).pick_list.stock_active.order(:name)
    full_list = resident_list + stock_list

    return full_list.group_by{ |x| x.type.demodulize.titleize.pluralize }# + stock_list
  end

  def district_list
    district_list = self.districts.pick_list.to_a
    self.wb_contributions.each do |cont|
      district_list << cont.district
    end

    return district_list.sort_by! { |dl| dl.name.downcase }
  end

  def images_sum
    sum = images.pluck(:file_file_size).sum.to_f
    return "#{(sum/1000000).round(1)} MB" if sum >= 1000000
    return "#{(sum/1000).round(1)} KB"
  end

  def resident_images_sum
    sum_a = resident_images.pluck(:file_file_size).to_a
    if sum_a.any?
      sum = sum_a.sum.to_f
      return "#{(sum/1000000).round(1)} MB" if sum >= 1000000
      return "#{(sum/1000).round(1)} KB"
    end
  end

  def can_auth(user)
    return false if user.nil?
    return true if self == user.resident
    false
  end

  def mark_for_removal
    self.gallery_image_join.mark_for_destruction if gallery_image_join && gallery_image_join.image_id.blank?
  end

  def self.search(search)
    return where("name ilike ?", "%#{search}%")
  end

  private
    def make_slug
      self.slug = self.name.parameterize
    end

end
