require "test_helper"

class DomainDocTest < ActiveSupport::TestCase
  TERMS = %w[Game Campaign Adventure Page World Module Published Catalog].freeze

  test "defines each milestone term exactly once" do
    TERMS.each do |term|
      assert_equal 1, definitions_of(term), "#{term} must have exactly one definition"
    end
  end

  test "says milestone issues update it as they ship" do
    assert_match(/living document/i, domain_doc)
    assert_match(/each milestone 7 issue updates it when it ships/i, domain_doc)
  end

  test "maps Stock content to Adventure Modules and Published entities" do
    rename_map = section("Rename map")

    assert_includes rename_map, "Stock Adventures → Adventure Modules"
    assert_includes rename_map, "Stock NPCs → Published NPCs"
    assert_includes rename_map, "Stock Creatures → Published Monsters"
    assert_includes rename_map, "Stock Items → Published Items"
    assert_includes rename_map, "Stock Spells → Published Spells"
    assert_includes rename_map, "browse surface → Catalog"
  end

  test "names District as the code name for World" do
    assert_includes section("Code names"), "World → `Worldbuilder::District`"
  end

  test "keeps Campagna in Italian and Campaign in Dutch" do
    translations = section("Translations")

    assert_includes translations, "Italian keeps \"Campagna\""
    assert_includes translations, "Dutch uses \"Campaign\""
    assert_no_match(/Dutch keeps "Campagne"/, translations)
  end

  test "says a Game references its content and never embeds it" do
    assert_match(/A Game references its content and never embeds it/, section("Target model"))
  end

  test "names the playlist states active, queued-future and retired" do
    playlist = section("Target model")[/playlist.*$/i].to_s

    %w[active queued-future retired].each { |state| assert_includes playlist, "`#{state}`" }
  end

  test "says a Campaign holds no live-play state" do
    assert_match(/A Campaign holds no live-play state/, section("Target model"))
  end

  test "says a Module owns its copy and keeps only a severable source link" do
    target_model = section("Target model")

    assert_match(/module owns a full self-contained copy/i, target_model)
    assert_match(/never depends on its source/i, target_model)
    assert_match(/optional, severable source link/i, target_model)
  end

  test "requires game-agnostic terms" do
    rules = section("Rules")

    assert_match(/game-agnostic terms/i, rules)
    assert_match(/no City-of-Brass theming/i, rules)
    assert_match(/no new Foundation-specific UI/i, rules)
  end

  test "defers date planning, ActivePlay unlocks and the to-be-overcome marker" do
    deferred = section("Deferred")

    assert_match(/date planning/i, deferred)
    assert_match(/ActivePlay unlocks/i, deferred)
    assert_match(/to be overcome/i, deferred)
  end

  test "is linked from AGENTS.md" do
    assert_includes Rails.root.join("AGENTS.md").read, "docs/domain.md"
  end

  private

  def domain_doc
    Rails.root.join("docs/domain.md").read
  end

  def section(heading)
    domain_doc[/^## #{Regexp.escape(heading)}\n(.*?)(?=^## |\z)/m, 1].to_s
  end

  def definitions_of(term)
    domain_doc.lines.count { |line| line.start_with?("- **#{term}** — ") }
  end
end
