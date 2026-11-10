require "test_helper"

class DiceRollerTest < ActionView::TestCase
  PARTIALS = [ "layouts/dice_roller", "layouts/dice_roller_basic" ].freeze

  test "escapes a quote in dice for both partials" do
    PARTIALS.each do |partial|
      render partial: partial, locals: { core_rules: "dnd5e", dice: "Standard'); alert(1);//", bonus: 3, display: "+3" }

      assert_includes onclick, "Standard\\'); alert(1);//"
    end
  end

  test "renders a valid dice mechanic unchanged" do
    PARTIALS.each do |partial|
      render partial: partial, locals: { core_rules: "dnd5e", dice: "2d6", bonus: 3, display: "+3" }

      assert_equal "roll_them_bones('dnd5e', '2d6', '3');", onclick
    end
  end

  private

  def onclick
    Nokogiri::HTML.fragment(rendered).at_css("a")["onclick"]
  end
end
