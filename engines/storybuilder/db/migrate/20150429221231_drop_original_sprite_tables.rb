class DropOriginalSpriteTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :storybuilder_character_sprites
    drop_table :storybuilder_creature_sprites
  end
end
