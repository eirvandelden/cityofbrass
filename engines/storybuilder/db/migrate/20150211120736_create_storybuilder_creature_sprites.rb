# frozen_string_literal: false

class CreateStorybuilderCreatureSprites < ActiveRecord::Migration
  def change
    create_table :storybuilder_creature_sprites, id: :uuid do |t|
      t.uuid :spriteable_id
      t.string :spriteable_type
      t.uuid :creature_id
      t.string :name
      t.integer :sort_order

      t.timestamps null: false
    end

    add_index :storybuilder_creature_sprites, :creature_id
    add_index :storybuilder_creature_sprites, [:spriteable_id, :spriteable_type], :name => 'sb_creature_sprite_id_and_type'
  end
end
