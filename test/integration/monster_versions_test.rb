require "test_helper"

class MonsterVersionsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner = users(:dan)
    @other = users(:lucas)
  end

  def create_version(creature, label)
    post "/eb/resident/creatures/#{creature.id}/versions", params: { version: { version_label: label } }
    Entitybuilder::Entity.find_by!(parent_id: creature.id, version_label: label)
  end

  test "parent lists its versions and each version links back" do
    sign_in @owner
    parent = entitybuilder_entities(:resident_creature_one)
    level_five = create_version(parent, "Level 5")
    level_ten = create_version(parent, "Level 10")

    get "/eb/resident/creatures/#{parent.id}"

    assert_response :success
    assert_select "a[href=?]", "/eb/resident/creatures/#{level_five.id}", text: /Level 5/
    assert_select "a[href=?]", "/eb/resident/creatures/#{level_ten.id}", text: /Level 10/

    get "/eb/resident/creatures/#{level_ten.id}"

    assert_response :success
    assert_select "a[href=?]", "/eb/resident/creatures/#{parent.id}"
  end

  test "pathfinder 2e creature gets a version without builder fields" do
    sign_in @owner
    parent = entitybuilder_entities(:resident_creature_pf2e)
    version = create_version(parent, "Elite")

    assert_redirected_to "/eb/resident/creatures/#{version.id}/edit"
    assert_equal "pf2e", version.core_rules
    assert_equal parent.name, version.name
  end

  test "version of a private monster stays private and owned by the same resident" do
    sign_in @owner
    parent = entitybuilder_entities(:resident_creature_private)
    version = create_version(parent, "Level 3")

    assert_equal parent.resident_id, version.resident_id
    assert_equal "Private", version.privacy
    assert_equal "Private", version.sheet_privacy
  end

  test "non-owner does not see a private version on the summary" do
    parent = entitybuilder_entities(:resident_creature_one)
    sign_in @owner
    version = create_version(parent, "Hidden")
    version.update_columns(privacy: "Private")
    sign_out @owner

    sign_in @other
    get "/eb/resident/creatures/#{parent.id}"

    assert_response :success
    assert_select "a[href=?]", "/eb/resident/creatures/#{version.id}", count: 0
  end

  test "creature index shows the version label" do
    sign_in @owner
    create_version(entitybuilder_entities(:resident_creature_one), "Level 10")

    get "/eb/resident/creatures"

    assert_response :success
    assert_select "li", text: /Level 10/
  end
end
