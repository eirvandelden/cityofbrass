# frozen_string_literal: false

class AddDetailToKnowItems < ActiveRecord::Migration
  def change
    add_column :entitybuilder_known_abilities, :detail, :string
    add_column :entitybuilder_known_feats, :detail, :string
    add_column :entitybuilder_known_spells, :detail, :string
    add_column :entitybuilder_inventory_items, :detail, :string
    add_column :entitybuilder_traits, :detail, :string
  end
end
