class CreateEntitybuilderNotables < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_notables, id: :string do |t|
      t.string :notableable_id
      t.string :notableable_type
      t.string :entity_id
      t.string :name
      t.integer :sort_order

      t.timestamps null: false
    end

    add_index :entitybuilder_notables, :entity_id
    add_index :entitybuilder_notables, [ :notableable_id, :notableable_type ], name: 'eb_notable_id_and_type'
  end
end
