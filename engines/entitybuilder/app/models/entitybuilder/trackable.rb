# frozen_string_literal: false

module Entitybuilder
  class Trackable < ApplicationRecord

    belongs_to :entity

    validates :name, uniqueness: { scope: :entity_id }, presence: true, length: { maximum: 64 }
    validates :description, length: { maximum: 6000 }
    validates :current, numericality: { only_integer: true, greater_than: -1000000, less_than: 1000000 }, allow_nil: true
    validates :temporary, numericality: { only_integer: true, greater_than: -1000000, less_than: 1000000 }, allow_nil: true
    validates :minimum, numericality: { only_integer: true, greater_than: -1000000, less_than: 1000000 }, allow_nil: true
    validates :maximum, numericality: { only_integer: true, greater_than: -1000000, less_than: 1000000 }, allow_nil: true
  end
end
