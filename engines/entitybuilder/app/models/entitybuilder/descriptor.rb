# frozen_string_literal: false

module Entitybuilder
  class Descriptor < ApplicationRecord

    scope :short, -> { select('name, description') }

    belongs_to :entity
    has_many :modifiers, -> { order(:sort_order) }, :as => :modifierable, :dependent => :destroy

    accepts_nested_attributes_for :modifiers, :allow_destroy => true

    validates :name, uniqueness: { scope: :entity_id }, presence: true, length: { maximum: 64 }
    validates :description, length: { maximum: 255 }
  end
end
