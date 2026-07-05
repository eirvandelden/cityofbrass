require "test_helper"
require "fileutils"

load Rails.root.join("db/migrate/20260703122205_add_service_name_to_active_storage_blobs.active_storage.rb")
load Rails.root.join("db/migrate/20260703122206_create_active_storage_variant_records.active_storage.rb")

class ActiveStorageRollbackTest < ActiveSupport::TestCase
  setup do
    @original_config = ActiveRecord::Base.connection_db_config
    @database_path = Rails.root.join("tmp", "active_storage_rollback_test_#{SecureRandom.hex}.sqlite3")

    FileUtils.mkdir_p(@database_path.dirname)
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: @database_path.to_s)

    create_active_storage_tables
  end

  teardown do
    ActiveRecord::Base.establish_connection(@original_config)
    FileUtils.rm_f(@database_path)
  end

  test "service name rollback preserves the column from the create migration" do
    AddServiceNameToActiveStorageBlobs.new.down

    assert_column_exists :active_storage_blobs, :service_name
  end

  test "variant records rollback preserves the table from the create migration" do
    CreateActiveStorageVariantRecords.new.migrate(:down)

    assert_table_exists :active_storage_variant_records
  end

  private
    def create_active_storage_tables
      connection.create_table :active_storage_blobs do |t|
        t.string :key, null: false
        t.string :filename, null: false
        t.string :content_type
        t.text :metadata
        t.string :service_name, null: false
        t.bigint :byte_size, null: false
        t.string :checksum, null: false
        t.datetime :created_at, null: false
      end

      connection.create_table :active_storage_variant_records do |t|
        t.belongs_to :blob, null: false, index: false
        t.string :variation_digest, null: false
      end
    end

    def assert_column_exists(table_name, column_name)
      assert connection.column_exists?(table_name, column_name), "#{table_name}.#{column_name} should exist"
    end

    def assert_table_exists(table_name)
      assert connection.table_exists?(table_name), "#{table_name} should exist"
    end

    def connection
      ActiveRecord::Base.connection
    end
end
