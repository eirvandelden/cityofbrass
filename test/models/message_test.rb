# frozen_string_literal: false

require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  test "should have the necessary required validators" do
    message = Message.new
    assert_not message.valid?
    assert_equal [:sender_id, :recipient_id, :subject], message.errors.keys
  end

end
