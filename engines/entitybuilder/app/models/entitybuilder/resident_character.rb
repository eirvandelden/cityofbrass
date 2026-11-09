module Entitybuilder
  class ResidentCharacter < Entity

    belongs_to :resident, -> { select('residents.id, residents.user_id, residents.name, residents.slug') }

    has_one :user,
            -> { select('users.id, email, status').where(status: User::ACTIVE_STATUS) },
            :through => :resident,
            :source => :user,
            :class_name => "User"

    validates :resident_id, presence: true

    def character_level
      [ class_levels.sum { |class_level| class_level.level.to_i }, 1 ].max
    end

    def icon
      'fa fa-shield'
    end

  end
end
