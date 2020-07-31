# frozen_string_literal: false

module Entitybuilder
  module DefensesHelper

    def eb_get_armor_class(defenses)
      return defenses.first unless defenses.nil?
    end

  end
end
