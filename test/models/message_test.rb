require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  test "should have the necessary required validators" do
    message = Message.new
    assert_not message.valid?
    assert_equal [:sender, :recipient, :sender_id, :recipient_id, :subject], message.errors.keys
  end

  test "search by subject returns matching message" do
    result = Message.search(messages(:message1).subject)
    assert_includes result, messages(:message1)
  end

  test "search by body text returns matching message" do
    messages(:message1).body = "<p>unique_body_search_term</p>"
    messages(:message1).save!

    result = Message.search("unique_body_search_term")
    assert_includes result, messages(:message1)
  end

  test "search escapes wildcard characters" do
    messages(:message1).update!(subject: "100% done")
    messages(:message2).update!(subject: "100x done")

    result = Message.search("100%")
    assert_includes result, messages(:message1)
    assert_not_includes result, messages(:message2)
  end

  test "blank search returns all messages" do
    result = Message.search("")
    assert_includes result, messages(:message1)
    assert_includes result, messages(:message2)
  end

end
