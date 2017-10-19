module Entitybuilder
  class CampaignJoin < ApplicationRecord

    belongs_to :campaign, :class_name => "Campaignmanager::Campaign"
    belongs_to :entity

  end
end
