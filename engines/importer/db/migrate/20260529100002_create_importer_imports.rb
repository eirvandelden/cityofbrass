class CreateImporterImports < ActiveRecord::Migration[6.1]
  def change
    create_table :importer_imports, id: :string do |t|
      t.string :resident_id
      t.string :preview_id
      t.string :mode, null: false
      t.string :source, null: false
      t.string :status, null: false
      t.datetime :started_at
      t.datetime :finished_at
      t.json :progress
      t.json :summary

      t.timestamps
    end

    add_index :importer_imports, :resident_id
    add_index :importer_imports, :preview_id
    add_index :importer_imports, :mode
    add_index :importer_imports, :status
  end
end
