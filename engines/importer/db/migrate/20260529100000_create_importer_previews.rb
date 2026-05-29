class CreateImporterPreviews < ActiveRecord::Migration[6.1]
  def change
    create_table :importer_previews, id: :string do |t|
      t.string :resident_id
      t.string :mode, null: false
      t.string :source, null: false
      t.string :status, null: false
      t.json :summary
      t.json :validation_errors
      t.datetime :expires_at

      t.timestamps
    end

    add_index :importer_previews, :resident_id
    add_index :importer_previews, :mode
    add_index :importer_previews, :status
  end
end
