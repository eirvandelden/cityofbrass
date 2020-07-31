# frozen_string_literal: false

module Entitybuilder
  module TrackablesHelper

    def eb_get_hit_points(trackables)
      return trackables.first unless trackables.nil?
    end

  end
end
