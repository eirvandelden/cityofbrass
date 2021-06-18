module ReservedNames
  extend ActiveSupport::Concern

  RESERVED_NAMES = [
    "admin",
    "support",
    "info",
    "help",
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
