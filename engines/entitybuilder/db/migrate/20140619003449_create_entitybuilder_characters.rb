class CreateEntitybuilderCharacters < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_characters, id: :string do |t|
      t.string :resident_id, null: false
      t.string :campaign_id
      t.string :name, null: false
      t.string :slug
      t.string :race
      t.string :privacy
      t.string :sheet_privacy
      t.string :core_rules
      t.string :short_description
      t.text :full_description
      t.text :notes

      t.timestamps
    end

    add_index :entitybuilder_characters, [ :resident_id, :slug ], unique: true
  end
end
