require "test_helper"

class JavascriptEventHandlersTest < ActiveSupport::TestCase
  test "application manifest does not require legacy navigation asset" do
    source = Rails.root.join("app/assets/javascripts/application.js").read

    assert_not_includes source, "//= require #{legacy_navigation_name}"
  end

  test "application layouts load Turbo as a module" do
    desktop_source = Rails.root.join("app/views/layouts/application.html.erb").read
    phone_source = Rails.root.join("app/views/layouts/application.html+phone.erb").read

    [ desktop_source, phone_source ].each do |source|
      assert_includes source, 'javascript_include_tag "turbo.min", type: "module", "data-turbo-track" => "reload"'
      assert_includes source, 'javascript_include_tag "application", "data-turbo-track" => "reload"'
      assert_includes source, 'stylesheet_link_tag "application", "data-turbo-track" => "reload"'
    end
  end

  test "README describes Turbo without contradicting the Hotwire stack" do
    source = Rails.root.join("README.md").read

    assert_includes source, "Turbo for fast page transitions"
    assert_not_includes source, "no SPA or Hotwire"
  end

  test "application handlers bound on persistent targets are reset on turbo load" do
    source = Rails.root.join("app/assets/javascripts/application.js").read

    assert_includes source, "$(document).on('turbo:load'"
    assert_includes source, "$(document).off('closed.fndtn.reveal.brasscore')"
    assert_includes source, "$(window).off('resize.brasscore')"
  end

  test "scroll to top handlers bound on persistent targets are reset on turbo load" do
    source = Rails.root.join("app/assets/javascripts/v1/scroll2top.js").read

    assert_includes source, "$(document).on('turbo:load'"
    assert_includes source, "$(window).off('scroll.scroll2top')"
  end

  test "popbox resets persistent document handlers before rebinding" do
    source = Rails.root.join("app/assets/javascripts/v1/popbox.js").read

    assert_includes source, "$(document).off('.popbox')"
    assert_includes source, "$(document).on('keyup.popbox'"
    assert_includes source, "$(document).on('touchstart.popbox click.popbox'"
  end

  test "alert close handlers bound on document are reset before rebinding" do
    source = Rails.root.join("app/assets/javascripts/v1/alert.js").read

    assert_includes source, "$(document).off('click.alertBox'"
    assert_includes source, "$(document).on('click.alertBox'"
    assert_not_includes source, '$(document).on("click", ".alert-box a.close"'
  end

  test "rulebuilder rule type selects keep native select behavior" do
    source = Rails.root.join("engines/rulebuilder/app/assets/javascripts/rulebuilder/rules.js").read

    assert_includes source, "$(document).on('turbo:load'"
    assert_includes source, ".rule-type-search"
    assert_includes source, ".rule-type-select"
    assert_includes source, "selectedCoreRules"
    assert_includes source, "typeof rule_type_param"
    assert_not_includes source, "select2"
  end

  test "application assets do not require select2" do
    javascript_source = Rails.root.join("app/assets/javascripts/application.js").read
    stylesheet_source = Rails.root.join("app/assets/stylesheets/application.scss").read

    assert_not_includes javascript_source, "require select2"
    assert_not_includes stylesheet_source, "require select2"
    assert_not Rails.root.join("app/assets/javascripts/v1/select2.js").exist?
    assert_not Rails.root.join("app/assets/stylesheets/v1/select2.foundation.scss").exist?
  end

  test "activeplay view scripts reset persistent turbo and resize handlers" do
    desktop_source = Rails.root.join("engines/activeplay/app/views/activeplay/virtual_tables/show.html.erb").read
    phone_source = Rails.root.join("engines/activeplay/app/views/activeplay/virtual_tables/show.html+phone.erb").read
    cleanup_events = "turbo:before-cache.activeplayCleanup turbo:before-visit.activeplayCleanup"

    assert_includes desktop_source, "$(document).off('#{cleanup_events}')"
    assert_includes desktop_source, "$(window).off('resize.activeplayCleanup')"
    assert_includes desktop_source, "$(window).on('resize.activeplayCleanup'"
    assert_includes phone_source, "$(document).off('#{cleanup_events}')"

    [ desktop_source, phone_source ].each do |source|
      assert_includes source, "$(document).on('#{cleanup_events}'"
      assert_not_includes source, "page:fetch"
    end
  end

  test "application and engine sources no longer use legacy navigation names" do
    sources = Rails.root.glob("{app,engines}/**/*.{erb,js,scss}").reject do |path|
      path.to_s.include?("/test/dummy/")
    end

    matches = sources.filter_map do |path|
      "#{path.relative_path_from(Rails.root)} uses legacy navigation" if legacy_navigation?(path.read)
    end

    assert_empty matches
  end

  private

  def legacy_navigation?(source)
    source.include?(legacy_navigation_name) || source.include?(legacy_navigation_constant)
  end

  def legacy_navigation_name
    "turbo" + "links"
  end

  def legacy_navigation_constant
    "Turbo" + "links"
  end
end
