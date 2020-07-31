# frozen_string_literal: false

module Entitybuilder
  class ResidentNpc < Entity

    belongs_to :resident, -> { select('residents.id, residents.user_id, residents.name, residents.slug') }

    has_one :user,
            -> { select('users.id, email, status').where(status: User::ACTIVE_STATUS) },
            :through => :resident,
            :source => :user,
            :class_name => "User"

    validates :resident_id, presence: true

    def icon
      'fa fa-male'
    end

  end
end
