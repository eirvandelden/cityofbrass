# frozen_string_literal: false

class CreateCampaignmanagerSprites < ActiveRecord::Migration
  def change
    create_table :campaignmanager_sprites, id: :uuid do |t|
      t.uuid :spriteable_id
      t.string :spriteable_type
      t.uuid :entity_id
      t.string :name
      t.integer :sort_order

      t.timestamps null: false
    end

    add_index :campaignmanager_sprites, :entity_id
    add_index :campaignmanager_sprites, [:spriteable_id, :spriteable_type], :name => 'cm_sprite_id_and_type'
  end
end
