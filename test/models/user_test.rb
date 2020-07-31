# frozen_string_literal: false

require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should have the necessary required validators" do
    user = users(:dan)
    user.status =""
    assert_not user.valid?
    assert_equal [:status], user.errors.keys
  end

end
