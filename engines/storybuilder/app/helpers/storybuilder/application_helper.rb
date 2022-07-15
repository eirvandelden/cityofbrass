module Storybuilder
  module ApplicationHelper
    def sb_record_types
      [
        ['Encounters', 'Storybuilder::Encounter'],
        ['Handouts', 'Storybuilder::Handout'],
        ['Adventures', 'Storybuilder::Story']
      ]
    end
  end
end
