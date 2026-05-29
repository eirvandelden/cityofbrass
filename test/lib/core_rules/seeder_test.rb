require "test_helper"

class CoreRulesSeederTest < ActiveSupport::TestCase
  test "seed_attributes preserves pre-rendered html descriptions" do
    attrs = {
      "full_description" => "<p>Already rendered</p>"
    }

    seeded_attrs = CoreRules::Seeder.seed_attributes(attrs, [ "full_description" ])

    assert_equal "<p>Already rendered</p>", seeded_attrs["full_description"]
  end

  test "seed_attributes renders markdown descriptions" do
    attrs = {
      "full_description" => "## Render me"
    }

    seeded_attrs = CoreRules::Seeder.seed_attributes(attrs, [ "full_description" ])

    assert_equal "<h2>Render me</h2>\n", seeded_attrs["full_description"]
  end
end
