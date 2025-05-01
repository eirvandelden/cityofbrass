module Storybuilder
  module PagesHelper

    def feature_special_options_encounter
      [
      ]
    end

    def feature_special_options_handout
      [
      ]
    end

    def feature_special_options_story
      [
      ]
    end

    def sb_icon_for(type)
      icons = [
        ['fa fa-random','Encounter'],
        ['fa fa-paperclip','Handout'],
        ['icon-open-book','Story']
      ]

      return icons.rassoc(type).first
    end

  end
end
