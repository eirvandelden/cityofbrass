require "test_helper"

class FooterTest < ActionView::TestCase
  test "renders localized copyright notice" do
    I18n.with_locale(:nl) do
      render partial: "layouts/footer"
    end

    assert_match(/Aangepast door Etienne van Delden de la Haije/, rendered)
    assert_no_match(/Modified by Etienne van Delden de la Haije/, rendered)
  end
end
