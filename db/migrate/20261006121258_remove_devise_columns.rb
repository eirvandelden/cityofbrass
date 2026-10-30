class RemoveDeviseColumns < ActiveRecord::Migration[8.1]
  USER_INDEXES = %i[confirmation_token reset_password_token unlock_token].freeze
  ADMIN_INDEXES = %i[reset_password_token unlock_token].freeze
  USER_COLUMNS = %i[
    encrypted_password confirmation_token confirmation_sent_at confirmed_at unconfirmed_email
    remember_created_at reset_password_token reset_password_sent_at unlock_token
  ].freeze
  ADMIN_COLUMNS = %i[
    encrypted_password remember_created_at reset_password_token reset_password_sent_at unlock_token
  ].freeze

  def up
    drop_devise(:users, USER_INDEXES, USER_COLUMNS)
    drop_devise(:admins, ADMIN_INDEXES, ADMIN_COLUMNS)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Dropped Devise columns cannot be restored; restore the backup instead."
  end

  private
    # if_exists: production may lack an index the development schema has. A missing column already passes on SQLite.
    def drop_devise(table, indexes, columns)
      indexes.each { |column| remove_index table, column: column, if_exists: true }
      columns.each { |column| remove_column table, column }
    end
end
