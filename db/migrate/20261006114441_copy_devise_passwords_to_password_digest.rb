class CopyDevisePasswordsToPasswordDigest < ActiveRecord::Migration[8.1]
  PEPPER_MESSAGE = "DEVISE_PEPPER is set; Devise hashes include the pepper and would not verify with " \
                   "has_secure_password. Remove the pepper only after confirming it is unused in production.".freeze

  def up
    raise PEPPER_MESSAGE if ENV["DEVISE_PEPPER"].present?

    %i[users admins].each { |table| copy_password_hashes(table) }
  end

  def down
    %i[users admins].each { |table| remove_column table, :password_digest }
  end

  private
    def copy_password_hashes(table)
      add_column table, :password_digest, :text
      execute "UPDATE #{table} SET password_digest = encrypted_password"
    end
end
