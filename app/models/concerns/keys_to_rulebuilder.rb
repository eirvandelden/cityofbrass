module KeysToRulebuilder
  extend ActiveSupport::Concern

    def can_show?(current_user, is_admin, record_type)
      return can_edit?(current_user, is_admin, record_type)
      return is_admin
    end

    def can_edit?(current_user, is_admin, record_type)
      return false if current_user.nil?
      return is_admin if record_type.classify.include?"Stock"
      return is_admin if record_type.classify.include?"Proprietary"
      return true if current_user.id == self.resident.user_id
      return false
    end

end
