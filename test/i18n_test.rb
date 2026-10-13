require "test_helper"
require "i18n/tasks"

class I18nTest < ActiveSupport::TestCase
  setup do
    @i18n = I18n::Tasks::BaseTask.new
  end

  test "Game reads Game, Spel and Gioco" do
    assert_equal "Game", I18n.t("domain.game", locale: :en)
    assert_equal "Spel", I18n.t("domain.game", locale: :nl)
    assert_equal "Gioco", I18n.t("domain.game", locale: :it)
  end

  test "no locale is missing a key" do
    missing = @i18n.missing_keys

    assert_empty missing, "Missing #{missing.leaves.count} i18n keys, run `bin/i18n-tasks missing' to show them"
  end

  test "every key is used" do
    unused = @i18n.unused_keys

    assert_empty unused, "#{unused.leaves.count} unused i18n keys, run `bin/i18n-tasks unused' to show them"
  end

  test "every locale file is normalized" do
    not_normalized = @i18n.non_normalized_paths

    message = "Run `bin/i18n-tasks normalize' to fix:\n#{not_normalized.join("\n")}"

    assert_empty not_normalized, message
  end
end
