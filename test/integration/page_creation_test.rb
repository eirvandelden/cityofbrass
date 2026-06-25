require "test_helper"

class PageCreationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @game_master = users(:dan)
    @adventure   = storybuilder_adventures(:resident_one)
    @campaign    = campaignmanager_campaigns(:resident_one)
  end

  test "storybuilder new page form posts to pages collection" do
    sign_in @game_master
    get "/sb/resident/adventures/#{@adventure.id}/pages/new"
    assert_response :success

    action = response.body[/<form[^>]*action=(?:"|\\")([^"\\]+)/, 1]
    assert action, "no <form action=...> in response body"
    assert_match %r{\A/sb/resident/adventures/#{@adventure.id}/pages/?\z}, action,
                 "new-page form must post to the pages collection, got #{action.inspect}"
  end

  test "campaignmanager new adventure_log form posts to adventure_logs collection" do
    sign_in @game_master
    get "/cm/campaigns/#{@campaign.id}/adventure_logs/new"
    assert_response :success

    action = response.body[/<form[^>]*action=(?:"|\\")([^"\\]+)/, 1]
    assert action, "no <form action=...> in response body"
    assert_match %r{\A/cm/campaigns/#{@campaign.id}/adventure_logs/?\z}, action,
                 "new adventure_log form must post to collection, got #{action.inspect}"
  end

  test "creating a storybuilder page without menu selection auto-creates a menu item" do
    sign_in @game_master

    assert_difference [ "Storybuilder::MenuItem.count", "Storybuilder::MenuItemJoin.count" ], 1 do
      post "/sb/resident/adventures/#{@adventure.id}/pages", params: { page: {
        name: "Auto Menu Page", privacy: "Residents",
        short_description: "test", full_description: "<p>test</p>",
        menu_item_join_attributes: { menu_item_id: "" }
      } }
    end

    page = Storybuilder::Page.find_by!(name: "Auto Menu Page")
    assert page.menu_item_join.present?, "page should have a menu_item_join"

    menu_item = page.menu_item_join.menu_item
    assert_equal @adventure, menu_item.menu_itemable
    assert_equal "Auto Menu Page", menu_item.item_label
    assert_equal "/pages/#{page.id}", menu_item.item_link
  end

  test "creating a storybuilder page with an explicit menu selection does not create an extra menu item" do
    sign_in @game_master

    existing_menu_item = storybuilder_menu_items(:menu_item1)

    assert_difference "Storybuilder::MenuItem.count", 0 do
      post "/sb/resident/adventures/#{@adventure.id}/pages", params: { page: {
        name: "Explicit Menu Page", privacy: "Residents",
        short_description: "test", full_description: "<p>test</p>",
        menu_item_join_attributes: { menu_item_id: existing_menu_item.id }
      } }
    end
  end

  test "creating a campaignmanager adventure_log auto-creates a menu item" do
    sign_in @game_master

    assert_difference [ "Storybuilder::MenuItem.count", "Storybuilder::MenuItemJoin.count" ], 1 do
      post "/cm/campaigns/#{@campaign.id}/adventure_logs", params: { adventure_log: {
        name: "Auto Log", privacy: "Residents",
        short_description: "test", full_description: "<p>test</p>"
      } }
    end

    page = Campaignmanager::AdventureLog.find_by!(name: "Auto Log")
    assert page.menu_item_join.present?, "adventure_log should have a menu_item_join"

    menu_item = page.menu_item_join.menu_item
    assert_equal @campaign, menu_item.menu_itemable
    assert_equal "Auto Log", menu_item.item_label
  end
end
