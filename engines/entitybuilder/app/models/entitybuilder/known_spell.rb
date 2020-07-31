# frozen_string_literal: false

module Entitybuilder
  class KnownSpell < ApplicationRecord

    scope :prepared, -> { where(prepared: true) }

    belongs_to :entity
    belongs_to :spell, :class_name => "Rulebuilder::Spell"

    validates :spell_id, presence: true, allow_nil: false
    validates :spell_class, length: { maximum: 64 }
    validates :level, numericality: { only_integer: true, greater_than: -1000, less_than: 1000 }, allow_nil: true
    validates :detail, length: { maximum: 40 }

    def name
      return spell.name
    end

  end
end
