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

  test "popbox resets persistent document handlers before rebinding" do
    source = Rails.root.join("app/assets/javascripts/v1/popbox.js").read

    assert_includes source, "$(document).off('.popbox')"
    assert_includes source, "$(document).on('keyup.popbox'"
    assert_includes source, "$(document).on('touchstart.popbox click.popbox'"
  end

  test "rulebuilder select2 widgets are destroyed before turbolinks caches the page" do
    source = Rails.root.join("engines/rulebuilder/app/assets/javascripts/rulebuilder/rules.js").read

    assert_includes source, "$(document).on('turbolinks:before-cache'"
    assert_includes source, ".select2-hidden-accessible"
    assert_includes source, ".select2('destroy')"
  end

  test "basic select2 widgets use the turbolinks lifecycle without cached reinitialization" do
    source = Rails.root.join("app/assets/javascripts/v1/select2.js").read

    assert_includes source, "$(document).on('turbolinks:load'"
    assert_includes source, "$(document).on('turbolinks:before-cache'"
    assert_includes source, ".select2-basic.select2-hidden-accessible"
    assert_includes source, ".select2('destroy')"
  end

  test "activeplay view scripts reset persistent turbolinks and resize handlers" do
    desktop_source = Rails.root.join("engines/activeplay/app/views/activeplay/virtual_tables/show.html.erb").read
    phone_source = Rails.root.join("engines/activeplay/app/views/activeplay/virtual_tables/show.html+phone.erb").read
    cleanup_events = "turbolinks:before-cache.activeplayCleanup turbolinks:before-visit.activeplayCleanup"

    assert_includes desktop_source, "$(document).off('#{cleanup_events}')"
    assert_includes desktop_source, "$(window).off('resize.activeplayCleanup')"
    assert_includes desktop_source, "$(window).on('resize.activeplayCleanup'"
    assert_includes phone_source, "$(document).off('#{cleanup_events}')"

    [ desktop_source, phone_source ].each do |source|
      assert_includes source, "$(document).on('#{cleanup_events}'"
      assert_not_includes source, "page:fetch"
    end
  end
end
