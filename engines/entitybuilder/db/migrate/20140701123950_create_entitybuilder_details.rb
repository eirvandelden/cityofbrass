class CreateEntitybuilderDetails < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_details, id: :string do |t|
      t.string :detailable_id
      t.string :detailable_type
      t.integer :sort_order
      t.string :name, null: false
      t.text :description
      t.string :value
      t.string :dice

      t.timestamps
    end

    add_index :entitybuilder_details, [ :detailable_id, :detailable_type ], name: 'eb_detail_id_and_type'
    add_index :entitybuilder_details, [ :detailable_id, :name ], unique: true, name: 'eb_detail_name'
  end
end
