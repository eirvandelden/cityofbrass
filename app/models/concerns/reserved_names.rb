# frozen_string_literal: false

module ReservedNames
  extend ActiveSupport::Concern

  RESERVED_NAMES = [
    "dan",
    "daniel",
    "luke",
    "lucas",
    "admin",
    "support",
    "info",
    "help",
    "embers",
    "brass",
    "embersdev",
    "embersds",
    "cityofbrass",
    "city-of-brass",
    "citybrass",
    "city-brass",
    "thecityofbrass",
    "the-city-of-brass",
    "eberron",
    "forgotten-realms",
    "the-forgotten-realms",
    "edit",
    "delete",
    "new",
    "superuser",
    "user"
    ]

    def name_not_reserved
      if name.present? && RESERVED_NAMES.include?(slug)
        errors.add(:name, "is not valid.")
      end
    end

end
