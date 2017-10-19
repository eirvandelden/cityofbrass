require 'test_helper'

class ResidentTest < ActiveSupport::TestCase

  test "should have the necessary required validators" do
    resident = Resident.new(name: "TestResident")
    assert_not resident.valid?
    assert_equal [:user_id], resident.errors.keys
  end

end
