require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "belongs to a user" do
    session_record = users(:dan).sessions.create!

    assert_equal users(:dan), Session.find(session_record.id).authenticatable
  end

  test "belongs to an admin with an integer id" do
    session_record = admins(:dan).sessions.create!

    assert_equal admins(:dan), Session.find(session_record.id).authenticatable
    assert_equal [ session_record ], admins(:dan).sessions.to_a
  end
end
