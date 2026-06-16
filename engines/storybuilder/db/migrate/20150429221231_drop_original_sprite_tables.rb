class DropOriginalSpriteTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :storybuilder_character_sprites, if_exists: true
    drop_table :storybuilder_creature_sprites, if_exists: true
  end
end
