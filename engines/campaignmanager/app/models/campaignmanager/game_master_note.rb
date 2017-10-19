module Campaignmanager
  class GameMasterNote < Page

    after_initialize :assign_default_privacy, if: 'new_record?'

    def icon
      'fa fa-lock'
    end

  end
end
