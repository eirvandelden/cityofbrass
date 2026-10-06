require "test_helper"
require Rails.root.join("db/migrate/20261006114441_copy_devise_passwords_to_password_digest")

class CopyDevisePasswordsToPasswordDigestTest < ActiveSupport::TestCase
  include SchemaChangingTestHelper

  setup do
    @connection = ActiveRecord::Base.connection
    %i[users admins].each { |table| restore_devise_shape(table) }
  end

  teardown do
    %i[users admins].each { |table| restore_current_shape(table) }
  end

  test "copies encrypted_password into password_digest" do
    insert_account(:users, "legacy-user-id", "hash-for-user")
    insert_account(:admins, 4242, "hash-for-admin")

    migrate_up

    assert_equal "hash-for-user", digest_of(:users, "legacy-user-id")
    assert_equal "hash-for-admin", digest_of(:admins, 4242)
  end

  test "keeps user and admin row counts" do
    insert_account(:users, "legacy-user-id", "hash-for-user")
    insert_account(:admins, 4242, "")
    counts = %i[users admins].map { |table| count_of(table) }

    migrate_up

    assert_equal counts, %i[users admins].map { |table| count_of(table) }
    assert_equal "", digest_of(:admins, 4242)
  end

  test "aborts when DEVISE_PEPPER is set" do
    with_pepper("secret") do
      error = assert_raises(RuntimeError) { migrate_up }

      assert_match "DEVISE_PEPPER is set", error.message
    end
  end

  private
    def restore_devise_shape(table)
      @connection.remove_column table, :password_digest
      return if @connection.column_exists?(table, :encrypted_password)

      @connection.add_column table, :encrypted_password, :text, default: "", null: false
    end

    def restore_current_shape(table)
      @connection.remove_column table, :encrypted_password if @connection.column_exists?(table, :encrypted_password)
      @connection.add_column table, :password_digest, :text unless @connection.column_exists?(table, :password_digest)
    end

    def insert_account(table, id, hash)
      columns = table == :users ? "id, email, status" : "id, email"
      extra = table == :users ? ", 'active'" : ""
      @connection.execute(
        "INSERT INTO #{table} (#{columns}, encrypted_password) " \
        "VALUES (#{@connection.quote(id)}, 'legacy-#{id}@example.com'#{extra}, #{@connection.quote(hash)})"
      )
    end

    def migrate_up
      CopyDevisePasswordsToPasswordDigest.new.migrate(:up)
    end

    def digest_of(table, id)
      @connection.select_value("SELECT password_digest FROM #{table} WHERE id = #{@connection.quote(id)}")
    end

    def count_of(table)
      @connection.select_value("SELECT COUNT(*) FROM #{table}")
    end

    def with_pepper(value)
      original = ENV["DEVISE_PEPPER"]
      ENV["DEVISE_PEPPER"] = value
      yield
    ensure
      ENV["DEVISE_PEPPER"] = original
    end
end
