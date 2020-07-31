# frozen_string_literal: false

module KeysToStorybuilder
  extend ActiveSupport::Concern

  def can_show?(current_user, is_admin, record_type = nil)
    return false if current_user.nil?
    return true if can_edit?(current_user, is_admin, record_type)
    return true if privacy == 'Residents'
    return true if privacy == 'Affiliates' && Affiliation.are_affiliates(current_user.resident, self.resident) rescue NoMethodError
    return is_admin
  end

  def can_edit?(current_user, is_admin, record_type)
    return false if current_user.nil?
    if record_type.present?
      return is_admin if record_type.classify.include?"Stock"
    end
    return true if self.resident.blank? && is_admin
    return true if self.resident.present? && current_user.id == self.resident.user_id
    return false
  end

end
