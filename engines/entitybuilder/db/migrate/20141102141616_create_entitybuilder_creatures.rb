class CreateEntitybuilderCreatures < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_creatures, id: :string do |t|
      t.string :resident_id, null: false
      t.string :name, null: false
      t.string :privacy
      t.string :core_rules
      t.string :short_description
      t.text :full_description
      t.text :notes

      t.timestamps
    end

    add_index :entitybuilder_creatures, :resident_id
  end
end
