# frozen_string_literal: false

module Campaignmanager
  module PagesHelper
    def cm_icon_for(type)
      icons = [
        ['fa fa-newspaper-o','AdventureLog'],
        ['fa fa-book','HouseRule'],
        ['fa fa-lock','GameMasterNote']
      ]

      return icons.rassoc(type).first
    end
  end
end
