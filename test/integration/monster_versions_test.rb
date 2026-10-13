require "test_helper"

class MonsterVersionsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner = users(:dan)
    @other = users(:lucas)
  end

  def create_version(creature, label, monster_level: nil)
    version_params = { version_label: label, monster_level: monster_level }.compact
    post "/eb/resident/creatures/#{creature.id}/versions", params: { version: version_params }
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

  test "non-owner does not see a private parent on a public version's summary" do
    parent = entitybuilder_entities(:resident_creature_private)
    sign_in @owner
    version = create_version(parent, "Level 3")
    version.update_columns(privacy: "Public")
    sign_out @owner

    sign_in @other
    get "/eb/resident/creatures/#{version.id}"

    assert_response :success
    assert_select "a[href=?]", "/eb/resident/creatures/#{parent.id}", count: 0
    assert_select "p", text: /Version of/, count: 0
  end

  test "creature index shows the version label" do
    sign_in @owner
    create_version(entitybuilder_entities(:resident_creature_one), "Level 10")

    get "/eb/resident/creatures"

    assert_response :success
    assert_select "li", text: /Level 10/
  end
  test "version at level 10 shows level 10 numbers" do
    sign_in @owner
    orc = entitybuilder_entities(:four_e_creature_built)
    version = create_version(orc, "Level 10", monster_level: 10)

    get "/eb/resident/creatures/#{version.id}/sheet"

    assert_response :success
    assert_equal 10, version.monster_level
    assert_select "tr.roll", text: /Fortitude\s+22/
    assert_select "tr.roll", text: /Will\s+22/
    assert_equal [ 104, 104 ], version.trackables.find_by(name: "Hit Points").then { |hp| [ hp.maximum, hp.current ] }
    assert_equal "10", version.descriptors.find_by(name: "Level").description
    assert_equal 5, orc.reload.monster_level
  end

  test "version keeps an edited armor class and marks it" do
    sign_in @owner
    orc = entitybuilder_entities(:four_e_creature_built)
    version = create_version(orc, "Level 10", monster_level: 10)

    get "/eb/resident/creatures/#{version.id}/sheet"

    assert_select ".sheet-over-big", text: "23"

    get "/eb/resident/creatures/#{version.id}/monster_build/edit"

    assert_response :success
    assert_select "tr", text: /Armor Class.*needs manual revision/im
    assert_select "tr", text: /Fortitude.*needs manual revision/im, count: 0
  end
end
