class CreateStorybuilderSprites < ActiveRecord::Migration
  def change
    create_table :storybuilder_sprites, id: :uuid do |t|
      t.uuid :spriteable_id
      t.string :spriteable_type
      t.uuid :entity_id
      t.string :name
      t.integer :sort_order

      t.timestamps null: false
    end

    add_index :storybuilder_sprites, :entity_id
    add_index :storybuilder_sprites, [:spriteable_id, :spriteable_type], :name => 'sb_sprite_id_and_type'
  end
end
