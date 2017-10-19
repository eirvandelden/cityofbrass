module Rulebuilder
  class ResidentRule < Rule

    belongs_to :resident, -> { select('residents.id, residents.user_id, residents.name, residents.slug') }

    has_one :user,
            -> { select('users.id, email, status').where(status: User::ACTIVE_STATUS) },
            :through => :resident,
            :source => :user,
            :class_name => "User"

    validates :resident_id, presence: true

  end
end
