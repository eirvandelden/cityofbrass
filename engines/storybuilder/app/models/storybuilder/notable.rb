module Storybuilder
  class Notable < ApplicationRecord

    scope :order_sort_order, -> { order(:sort_order) }

    belongs_to :notableable, :polymorphic => true
    belongs_to :entity, :class_name => "Entitybuilder::Entity"

    validates :entity, presence: true
    validates :name, presence: true, length: { maximum: 64 }

  end
end
