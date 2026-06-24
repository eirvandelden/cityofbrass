require "test_helper"

load Rails.root.join("db/migrate/20260622195600_backfill_action_text_rich_texts.rb")

class BackfillActionTextRichTextsTest < ActiveSupport::TestCase
  LEGACY_BODY = "<p>legacy backfill test content</p>".freeze

  setup do
    @message = messages(:message1)
    Message.where(id: @message.id).update_all(body: LEGACY_BODY)
    ActionText::RichText.where(record_type: "Message", record_id: @message.id, name: "body").delete_all
  end

  teardown do
    ActionText::RichText.where(record_type: "Message", record_id: @message.id, name: "body").delete_all
  end

  test "up creates a rich text record from the legacy column" do
    BackfillActionTextRichTexts.new.up

    @message.reload
    assert_includes @message.body.to_plain_text, "legacy backfill test content"
  end

  test "up is idempotent: running twice does not create a duplicate row" do
    BackfillActionTextRichTexts.new.up
    BackfillActionTextRichTexts.new.up

    count = ActionText::RichText.where(record_type: "Message", record_id: @message.id, name: "body").count
    assert_equal 1, count
  end
end
