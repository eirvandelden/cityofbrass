module Entitybuilder
  class CampaignJoin < ApplicationRecord

    belongs_to :campaign, :class_name => "Campaignmanager::Campaign", optional: true
    belongs_to :entity, inverse_of: :campaign_join

  end
end
