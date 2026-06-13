module KeysToRulebuilder
  extend ActiveSupport::Concern

    def can_show?(current_user, is_admin, record_type)
      if self.class.const_defined?(:PRIVACY_OPTIONS)
        return true if privacy == "Public"
        return false if current_user.nil?
        return true if can_edit?(current_user, is_admin, record_type)
        return true if privacy == "Residents"
        return true if privacy == "Friends" && Affiliation.are_affiliates(current_user.resident, self.resident) rescue NoMethodError
        return is_admin
      else
        return can_edit?(current_user, is_admin, record_type)
      end
    end

    def can_edit?(current_user, is_admin, record_type)
      return false if current_user.nil?
      return is_admin if record_type.classify.include?"Stock"
      return true if current_user.id == self.resident.user_id
      return false
    end

end
