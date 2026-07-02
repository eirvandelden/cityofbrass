module Worldbuilder
  class MenuItemJoin < ApplicationRecord

  	belongs_to :menu_item, optional: true
    belongs_to :menu_item_joinable, :polymorphic => true, inverse_of: :menu_item_join

    validates :menu_item_joinable_type, presence: true

  end
end
