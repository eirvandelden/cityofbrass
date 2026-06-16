require "test_helper"

class AdminStockEntityNavigationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:dan)
    @admin = admins(:dan)
    @creature = entitybuilder_entities(:stock_creature_one)
    @character = entitybuilder_entities(:resident_character_one)
    @adventure = storybuilder_adventures(:resident_one)
    @rule = rulebuilder_rules(:stock_one)
    @image = gallery_images(:stock_one)
  end

  test "entity detail pages keep admin stock links" do
    sign_in @user
    sign_in @admin

    [ "", "/profile", "/sheet", "/card" ].each do |path|
      get "/eb/admin/stock/creatures/#{@creature.id}#{path}"

      assert_response :success
      assert_select "a[href='/eb/admin/stock/creatures/#{@creature.id}/edit']"
      assert_select "a[href^='/eb/stock/creatures/#{@creature.id}']", false
    end
  end

  test "nested entity pages keep admin stock links" do
    sign_in @user
    sign_in @admin

    get "/eb/admin/stock/creatures/#{@creature.id}/descriptors"

    assert_response :success
    assert_select "a[href='/eb/admin/stock/creatures/#{@creature.id}/descriptors/new']"
  end

  test "rule detail pages keep admin stock links" do
    sign_in @user
    sign_in @admin

    get "/rb/admin/stock/rules/#{@rule.id}"

    assert_response :success
    assert_select "a[href='/rb/admin/stock/rules/#{@rule.id}/edit']"
  end

  test "image detail pages keep admin stock links" do
    sign_in @user
    sign_in @admin

    get "/gallery/admin/stock/images/#{@image.id}"

    assert_response :success
    assert_select "a[href='/gallery/admin/stock/images/#{@image.id}/edit']"
    assert_select "a[href='/gallery/admin/stock/images']"
  end

  test "admin can add stock notables for non-stock entity core rules" do
    @character.update!(core_rules: "generic")
    sign_in @user
    sign_in @admin

    get "/eb/resident/characters/#{@character.id}/notables"

    assert_response :success
    assert_select "a[href='/eb/resident/characters/#{@character.id}/notables/new?entity_type=stock_creature']"
  end

  test "admin can add stock notables for non-stock adventure core rules" do
    @adventure.update!(core_rules: "generic")
    sign_in @user
    sign_in @admin

    get "/sb/resident/adventures/#{@adventure.id}/notables"

    assert_response :success
    assert_select "a[href='/sb/resident/adventures/#{@adventure.id}/notables/new?entity_type=stock_creature']"
  end
end
