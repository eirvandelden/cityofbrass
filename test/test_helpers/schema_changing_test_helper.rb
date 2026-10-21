# For tests that alter the users and admins tables inside the test transaction.
# SQLite rebuilds a table to drop a column, and the fixture rollback rebuilds it
# again; cached prepared statements and column information would still describe
# the in-test shape. Clear both once the rollback is done.
module SchemaChangingTestHelper
  def after_teardown
    super
    ActiveRecord::Base.lease_connection.clear_cache!
    User.reset_column_information
    Admin.reset_column_information
  end
end
