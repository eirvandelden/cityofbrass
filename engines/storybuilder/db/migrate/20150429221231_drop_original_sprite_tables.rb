# frozen_string_literal: false

class DropOriginalSpriteTables < ActiveRecord::Migration
  def change
    drop_table :storybuilder_character_sprites
    drop_table :storybuilder_creature_sprites
  end
end
