class Current < ActiveSupport::CurrentAttributes
  attribute :user_session, :admin_session

  def session_ids
    [ user_session, admin_session ].compact.map(&:id)
  end
end
