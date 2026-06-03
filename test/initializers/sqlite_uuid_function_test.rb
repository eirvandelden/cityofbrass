require "test_helper"

class SqliteUuidFunctionTest < ActiveSupport::TestCase
  test "sqlite connections provide a uuid function" do
    skip "SQLite only" unless sqlite?

    uuid = ActiveRecord::Base.connection.select_value("SELECT uuid()")

    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/, uuid)
  end

  private

  def sqlite?
    ActiveRecord::Base.connection.adapter_name == "SQLite"
  end
end
