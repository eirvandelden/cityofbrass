module Storybuilder
  module PagesHelper

    def feature_special_options_encounter
      special_options = [
      ]
    end

    def feature_special_options_handout
      special_options = [
      ]
    end

    def feature_special_options_story
      special_options = [
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
