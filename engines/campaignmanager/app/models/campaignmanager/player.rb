module Campaignmanager
  class Player < ApplicationRecord

    NULL_ATTRS = %w( affiliation_id )

    belongs_to :campaign
    belongs_to :affiliation

    has_one :affiliate,
            -> { select('residents.id, residents.user_id, residents.name, residents.slug') .order(:name) },
            :through => :affiliation,
            :class_name => "Resident",
            :foreign_key => "affiliate_id"
    has_one :affiliate_user,
            -> { select('users.id, email') },
            :through => :affiliate,
            :source => :user,
            :class_name => "User"

    has_one :campaign_resident,
            :through => :campaign,
            :source => :resident,
            :class_name => "Resident"
    has_one :campaign_user,
            -> { select('users.id, email').where(status: User::ACTIVE_STATUS) },
            :through => :campaign_resident,
            :source => :user,
            :class_name => "User"

    validates :campaign_id,    presence: true
    validates :affiliation_id, presence: true, uniqueness: { scope: :campaign_id }

    before_validation :nil_if_blank

    private
      def nil_if_blank
        NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
      end

  end
end
