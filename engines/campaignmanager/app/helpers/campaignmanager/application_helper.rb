module Campaignmanager
  module ApplicationHelper
    def cm_record_types
      options = [
        ['Adventure Logs', 'Campaignmanager::AdventureLog'],
        ['House Rules', 'Campaignmanager::HouseRule'],
        ['Game Master Notes', 'Campaignmanager::GameMasterNote']
      ]
    end
  end
end
