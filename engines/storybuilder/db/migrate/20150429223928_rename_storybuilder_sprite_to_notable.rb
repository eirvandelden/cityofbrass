# frozen_string_literal: false

class RenameStorybuilderSpriteToNotable < ActiveRecord::Migration
  def change
    remove_index :storybuilder_sprites, :name => 'sb_sprite_id_and_type'

    rename_column :storybuilder_sprites, :spriteable_id, :notableable_id
    rename_column :storybuilder_sprites, :spriteable_type, :notableable_type

    rename_table :storybuilder_sprites, :storybuilder_notables

    add_index :storybuilder_notables, [:notableable_id, :notableable_type], :name => 'sb_notable_id_and_type'
  end
end
