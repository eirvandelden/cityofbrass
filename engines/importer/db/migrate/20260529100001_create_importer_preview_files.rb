class CreateImporterPreviewFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :importer_preview_files, id: :string do |t|
      t.string :preview_id, null: false
      t.string :detected_kind, null: false
      t.string :override_kind
      t.json :entity_counts
      t.json :parse_errors

      t.timestamps
    end

    add_column :importer_preview_files, :file_file_name, :string
    add_column :importer_preview_files, :file_content_type, :string
    add_column :importer_preview_files, :file_file_size, :bigint
    add_column :importer_preview_files, :file_updated_at, :datetime

    add_index :importer_preview_files, :preview_id
    add_index :importer_preview_files, :detected_kind
  end
end
