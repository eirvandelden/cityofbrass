require "test_helper"
require Rails.root.join("db/migrate/20261006114441_copy_devise_passwords_to_password_digest")

class LegacyPasswordTest < ActionDispatch::IntegrationTest
  # Generated once with BCrypt::Password.create("legacy-password", cost: 10): the shape Devise stores, no pepper.
  LEGACY_HASH = "$2a$10$KBfSqkfEtvgXwAOFG4wxB.b/Hd2nzt7JTkXPcMgKS07im3Fip4AE6".freeze

  setup do
    @connection = ActiveRecord::Base.connection
    %i[users admins].each { |table| install_legacy_hash(table) }
    CopyDevisePasswordsToPasswordDigest.new.migrate(:up)
    User.reset_column_information
    Admin.reset_column_information
  end

  teardown do
    %i[users admins].each { |table| restore_current_shape(table) }
    User.reset_column_information
    Admin.reset_column_information
  end

  test "user with a copied devise hash signs in" do
    post user_session_path, params: { user: { email: users(:dan).email, password: "legacy-password" } }

    assert_redirected_to root_url
  end

  test "admin with a copied devise hash signs in" do
    post admin_session_path, params: { admin: { email: admins(:dan).email, password: "legacy-password" } }

    assert_redirected_to root_url
  end

  private
    def install_legacy_hash(table)
      @connection.remove_column table, :password_digest
      add_encrypted_password(table)
      @connection.execute("UPDATE #{table} SET encrypted_password = #{@connection.quote(LEGACY_HASH)}")
    end

    def add_encrypted_password(table)
      return if @connection.column_exists?(table, :encrypted_password)

      @added = (@added || []) << table
      @connection.add_column table, :encrypted_password, :text, default: "", null: false
    end

    def restore_current_shape(table)
      @connection.remove_column table, :encrypted_password if @added&.include?(table)
      @connection.add_column table, :password_digest, :text unless @connection.column_exists?(table, :password_digest)
    end
end
