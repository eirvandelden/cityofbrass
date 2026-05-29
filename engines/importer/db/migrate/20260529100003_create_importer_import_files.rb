class CreateImporterImportFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :importer_import_files, id: :string do |t|
      t.string :import_id, null: false
      t.string :kind, null: false
      t.string :parse_status, null: false, default: "pending"
      t.json :parse_errors

      t.timestamps
    end

    add_column :importer_import_files, :file_file_name, :string
    add_column :importer_import_files, :file_content_type, :string
    add_column :importer_import_files, :file_file_size, :bigint
    add_column :importer_import_files, :file_updated_at, :datetime

    add_index :importer_import_files, :import_id
    add_index :importer_import_files, :kind
    add_index :importer_import_files, :parse_status
  end
end
