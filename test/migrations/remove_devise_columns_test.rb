require "test_helper"
require Rails.root.join("db/migrate/20261006121258_remove_devise_columns")

class RemoveDeviseColumnsTest < ActiveSupport::TestCase
  KEPT_COLUMNS = %w[failed_attempts locked_at sign_in_count current_sign_in_at current_sign_in_ip
                    last_sign_in_at last_sign_in_ip].freeze

  test "drops devise only columns and keeps tracking columns" do
    %i[users admins].each { |table| assert_devise_columns_gone(table) }
    %i[users admins].each { |table| assert_empty KEPT_COLUMNS - column_names(table) }
  end

  test "is irreversible" do
    assert_raises(ActiveRecord::IrreversibleMigration) { RemoveDeviseColumns.new.down }
  end

  private
    def assert_devise_columns_gone(table)
      devise_columns = RemoveDeviseColumns::USER_COLUMNS + RemoveDeviseColumns::ADMIN_COLUMNS

      assert_empty devise_columns.map(&:to_s) & column_names(table)
    end

    def column_names(table)
      ActiveRecord::Base.connection.columns(table).map(&:name)
    end
end
