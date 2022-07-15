module KeysToBilling
  extend ActiveSupport::Concern

    def can_show?(current_user, is_admin=false)
      return can_edit?(current_user, is_admin=false)
      return is_admin
    end

    def can_edit?(current_user, _is_admin=false)
      return false if current_user.nil?
      return true if current_user.id == self.user_id
      return false
    end

end
