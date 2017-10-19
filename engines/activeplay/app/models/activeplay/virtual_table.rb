module Activeplay
  class VirtualTable < ApplicationRecord
    include KeysToCampaignmanager

    belongs_to :campaign,
               :class_name => "Campaignmanager::Campaign",
               :foreign_key => "campaign_id"

    has_one :resident,
            -> { select('residents.id, residents.user_id, residents.name, residents.slug') },
            :through => :campaign,
            :source => :resident,
            :class_name => "Resident"

    has_one :user,
            -> { select('users.id, email, status').where(status: User::ACTIVE_STATUS) },
            :through => :resident,
            :source => :user,
            :class_name => "User"

    has_many :entity_joins,
             :through => :campaign,
             :class_name => "Entitybuilder::CampaignJoin"

    has_many :characters,
             -> { select('entitybuilder_entities.id, entitybuilder_entities.type, entitybuilder_entities.resident_id, entitybuilder_entities.privacy, entitybuilder_entities.sheet_privacy, entitybuilder_entities.name, entitybuilder_entities.core_rules, entitybuilder_entities.short_description').order(:name) },
             :through => :entity_joins,
             :class_name => "Entitybuilder::ResidentCharacter",
             :source => :entity

    has_many :players,
             :through => :campaign,
             :class_name => "Campaignmanager::Player"

    has_many :notables, -> { order(:sort_order) }, :dependent => :destroy

    accepts_nested_attributes_for :notables, :allow_destroy => true

    validates :campaign_id, presence: true

    def privacy
      return campaign.privacy
    end

  end
end
