module KeysToEntitybuilder
  extend ActiveSupport::Concern

    def can_show?(current_user, is_admin, record_type)
      return false if current_user.nil?
      return true if can_edit?(current_user, is_admin, record_type)
      return true if privacy == 'Residents'
      return true if privacy == 'Affiliates' && Affiliation.are_affiliates(current_user.resident, self.resident) rescue NoMethodError
      return true if privacy == 'Private' && (record_type.include?"Character") && self.campaign && current_user.resident == self.campaign.resident
      return true if can_edit?(current_user, is_admin, record_type)
      return is_admin
    end

    def can_sheet?(current_user, is_admin, record_type)
      return false if current_user.nil?
      return true if can_edit?(current_user, is_admin, record_type)
      return true if sheet_privacy == 'Residents'
      return true if sheet_privacy == 'Affiliates' && Affiliation.are_affiliates(current_user.resident, self.resident) rescue NoMethodError
      return true if sheet_privacy == 'Private' && (record_type.include?"Character") && self.campaign && current_user.resident == self.campaign.resident
      return true if can_edit?(current_user, is_admin, record_type)
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
