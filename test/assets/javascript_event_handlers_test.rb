require "test_helper"

class JavascriptEventHandlersTest < ActiveSupport::TestCase
  test "application handlers bound on persistent targets are reset on turbolinks load" do
    source = Rails.root.join("app/assets/javascripts/application.js").read

    assert_includes source, "$(document).off('closed.fndtn.reveal.brasscore')"
    assert_includes source, "$(window).off('resize.brasscore')"
  end

  test "scroll to top handlers bound on persistent targets are reset on turbolinks load" do
    source = Rails.root.join("app/assets/javascripts/v1/scroll2top.js").read

    assert_includes source, "$(window).off('scroll.scroll2top')"
  end
end
