# frozen_string_literal: false

class RenameCampaignmanagerSpriteToNotable < ActiveRecord::Migration
  def change
    remove_index :campaignmanager_sprites, :name => 'cm_sprite_id_and_type'

    rename_column :campaignmanager_sprites, :spriteable_id, :notableable_id
    rename_column :campaignmanager_sprites, :spriteable_type, :notableable_type

    rename_table :campaignmanager_sprites, :campaignmanager_notables

    add_index :campaignmanager_notables, [:notableable_id, :notableable_type], :name => 'cm_notable_id_and_type'
  end
end
