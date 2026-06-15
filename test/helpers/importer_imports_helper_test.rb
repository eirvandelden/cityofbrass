require "test_helper"

class ImporterImportsHelperTest < ActionView::TestCase
  include Importer::ImportsHelper

  test "known import failure reasons use translations" do
    assert_equal "Already exists", importer_reason_label("already exists")
  end

  test "unknown import failure reasons render the stored message" do
    reason = "Validation failed: Name can't be blank"

    assert_equal reason, importer_reason_label(reason)
  end
end
