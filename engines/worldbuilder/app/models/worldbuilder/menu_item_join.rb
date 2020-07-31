# frozen_string_literal: false

module Worldbuilder
  class MenuItemJoin < ApplicationRecord

  	belongs_to :menu_item
    belongs_to :menu_item_joinable, :polymorphic => true

    validates :menu_item_joinable_type, presence: true

  end
end
