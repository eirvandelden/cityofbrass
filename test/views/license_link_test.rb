require "test_helper"

class LicenseLinkTest < ActionView::TestCase
  test "does not render a modal link when no FAQ lookup key exists" do
    render partial: "layouts/license/link", locals: { core_rules: "Draw Steel" }

    assert_no_match(/scrolls\/license/, rendered)
  end

  test "does not render attribution when system only has a FAQ lookup key" do
    render partial: "layouts/license/attribution", locals: { core_rules: "PFRPG" }

    assert_no_match(/rpg-system-attribution/, rendered)
    assert_no_match(/License d20 OGL/, rendered)
  end

  test "does not render a modal link for 4th Edition" do
    render partial: "layouts/license/link", locals: { core_rules: "4th Edition" }

    assert_no_match(/scrolls\/license/, rendered)
  end

  test "does not render attribution for 4th Edition" do
    render partial: "layouts/license/attribution", locals: { core_rules: "4th Edition" }

    assert_no_match(/rpg-system-attribution/, rendered)
    assert_no_match(/Game System License/, rendered)
  end
end
