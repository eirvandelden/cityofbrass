class CreateActiveplayNotables < ActiveRecord::Migration[4.2]
  def change
    create_table :activeplay_notables, id: :string do |t|
      t.string :name
      t.integer :sort_order
      t.string :virtual_table_id
      t.string :entity_id

      t.timestamps null: false
    end

    add_index :activeplay_notables, :virtual_table_id
    add_index :activeplay_notables, :entity_id
  end
end
