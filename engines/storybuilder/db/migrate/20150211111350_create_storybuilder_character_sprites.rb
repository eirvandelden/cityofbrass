class CreateStorybuilderCharacterSprites < ActiveRecord::Migration[4.2]
  def change
    create_table :storybuilder_character_sprites, id: :string do |t|
      t.string :spriteable_id
      t.string :spriteable_type
      t.string :character_id
      t.string :name
      t.integer :sort_order

      t.timestamps null: false
    end

    add_index :storybuilder_character_sprites, :character_id
    add_index :storybuilder_character_sprites, [ :spriteable_id, :spriteable_type ], name: 'sb_character_sprite_id_and_type'
  end
end
