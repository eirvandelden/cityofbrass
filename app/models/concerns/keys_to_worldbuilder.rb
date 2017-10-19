module KeysToWorldbuilder
  extend ActiveSupport::Concern

  def can_show?(current_user, is_admin)
    return true if privacy == 'Public'
    return false if current_user.nil?
    return true if privacy == 'Residents'
    return true if privacy == 'Affiliates' && Affiliation.are_affiliates(current_user.resident, self.resident)
    return true if can_edit?(current_user, is_admin)
    return is_admin
  end

  def can_edit?(current_user, is_admin)
    return false if current_user.nil?
    return true if current_user.id == self.resident.user_id
    return true if self.contributors.any? {|c| c.affiliate_user == current_user}
    return false
  end

end
