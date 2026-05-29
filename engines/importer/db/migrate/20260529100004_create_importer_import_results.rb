class CreateImporterImportResults < ActiveRecord::Migration[6.1]
  def change
    create_table :importer_import_results, id: :string do |t|
      t.string :import_file_id, null: false
      t.string :entity_type, null: false
      t.string :entity_name, null: false
      t.string :outcome, null: false
      t.text :reason
      t.string :record_type
      t.string :record_id

      t.timestamps
    end

    add_index :importer_import_results, :import_file_id
    add_index :importer_import_results, :outcome
    add_index :importer_import_results, [ :record_type, :record_id ]
  end
end
