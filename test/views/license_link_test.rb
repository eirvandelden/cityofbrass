require "test_helper"

class LicenseLinkTest < ActionView::TestCase
  test "does not render a modal link when no FAQ lookup key exists" do
    render partial: "layouts/license/link", locals: { core_rules: "Draw Steel" }

    assert_no_match(/scrolls\/license/, rendered)
  end
end
