# frozen_string_literal: false

module Storybuilder
  module ApplicationHelper
    def sb_record_types
      options = [
        ['Encounters', 'Storybuilder::Encounter'],
        ['Handouts', 'Storybuilder::Handout'],
        ['Stories', 'Storybuilder::Story']
      ]
    end
  end
end
