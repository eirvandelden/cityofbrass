module Storybuilder
  class MenuItem < ApplicationRecord

    scope :order_sort_order, -> { order(:sort_order) }

  	belongs_to :menu_itemable, :polymorphic => true

    validates :menu_itemable_type, presence: true, allow_nil: false
    validates :item_label, presence: true, length: { maximum: 25 }

  end
end
