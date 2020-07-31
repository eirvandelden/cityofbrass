# frozen_string_literal: false

module Entitybuilder
  module MovementsHelper

    def eb_get_initiative(movements)
      return movements.detect { |d| d.name == "Initiative" } unless movements.nil?
    end

    def eb_get_speed(movements)
      return movements.reject { |d| d.name == "Initiative" }.first unless movements.nil?
    end

  end
end
