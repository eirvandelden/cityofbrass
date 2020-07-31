# frozen_string_literal: false

module KeysToCampaignmanager
  extend ActiveSupport::Concern

  def can_show?(current_user, is_admin, record_type = 'Campaignmanager::Campaign')
    return true if is_admin
    return true if privacy == 'Public' && record_type != 'Activeplay::Campaign'
    return false if current_user.nil?
    return true if can_edit?(current_user, is_admin)
    return false if record_type == 'Campaignmanager::GameMasterNote'
    if record_type == 'Activeplay::Campaign'
      return true if self.players.any? {|c| c.affiliate == current_user.resident}  rescue NoMethodError
      return false
    else
      return true if privacy == 'Residents'
      return true if privacy == 'Affiliates' && Affiliation.are_affiliates(current_user.resident, self.resident) rescue NoMethodError
      return true if privacy == 'Private' && record_type == 'Campaignmanager::Campaign' && self.players.any? {|c| c.affiliate == current_user.resident}  rescue NoMethodError
      # page permissions
      return true if privacy == 'Private' && record_type != 'Campaignmanager::Campaign' && self.campaign.players.any? {|c| c.affiliate == current_user.resident}  rescue NoMethodError
    end
  end

  def can_edit?(current_user, is_admin)
    return false if current_user.nil?
    return true if current_user.id == self.resident.user_id
    return false
  end

end
