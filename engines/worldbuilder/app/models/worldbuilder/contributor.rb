# frozen_string_literal: false

module Worldbuilder
  class Contributor < ApplicationRecord

    NULL_ATTRS = %w( affiliation_id )

    belongs_to :district
    belongs_to :affiliation

    has_one :affiliate,
            :through => :affiliation,
            :class_name => "Resident",
            :foreign_key => "affiliate_id"
    has_one :affiliate_user,
            -> { select('users.id, email') },
            :through => :affiliate,
            :source => :user,
            :class_name => "User"

    has_one :district_resident,
            :through => :district,
            :source => :resident,
            :class_name => "Resident"
    has_one :district_user,
            -> { select('users.id, email').where(status: User::ACTIVE_STATUS) },
            :through => :district_resident,
            :source => :user,
            :class_name => "User"

    validates :district_id,    presence: true
    validates :affiliation_id, presence: true, uniqueness: { scope: :district_id }

    before_validation :nil_if_blank

    private
      def nil_if_blank
        NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
      end

  end
end
