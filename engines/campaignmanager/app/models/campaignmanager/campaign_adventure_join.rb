module Campaignmanager
  class CampaignAdventureJoin < ApplicationRecord
    belongs_to :campaign, class_name: "Campaignmanager::Campaign"
    belongs_to :adventure, class_name: "Storybuilder::Adventure"

    validates :adventure_id, uniqueness: { scope: :campaign_id }
  end
end
