require "test_helper"

class RulebuilderItemPrivacyTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  ENTITY_CASES = [
    [ "resident character", :resident_character_one, "/eb/resident/characters" ],
    [ "resident creature", :resident_creature_one, "/eb/resident/creatures" ],
    [ "resident npc", :resident_npc_one, "/eb/resident/npcs" ],
    [ "stock creature", :stock_creature_one, "/eb/stock/creatures" ],
    [ "stock npc", :stock_npc_one, "/eb/stock/npcs" ]
  ]

  ITEM_CASES = [
    [ "resident item", Rulebuilder::ResidentItem ],
    [ "stock item", Rulebuilder::StockItem ]
  ]

  HIDDEN_FROM_PUBLIC = [ "Private", "Residents" ]
  PUBLIC_ENTITY_ENDPOINTS = [
    [ "sheet", "sheet", false, :full ],
    [ "profile", "profile", false, :name ],
    [ "card", "card", false, :full ],
    [ "card summary", "card_summary.js", true, :none ]
  ]

  setup do
    @owner = users(:dan)
    @viewer = users(:lucas)
    @resident = residents(:razune)
  end

  ENTITY_CASES.each do |entity_label, entity_fixture, entity_path|
    ITEM_CASES.each do |item_label, item_class|
      HIDDEN_FROM_PUBLIC.each do |privacy|
        PUBLIC_ENTITY_ENDPOINTS.each do |endpoint_label, endpoint_path, xhr, visible_assertion|
          test "public #{entity_label} #{endpoint_label} hides #{privacy.downcase} #{item_label} from guests" do
            entity = public_entity(entity_fixture)
            hidden_item = create_item(item_class, privacy: privacy, name: hidden_name)
            hidden_inventory_item = attach_item(entity, hidden_item)
            visible_item = create_item(item_class, privacy: "Public", name: visible_name)

            attach_item(entity, visible_item)

            get "#{entity_path}/#{entity.id}/#{endpoint_path}", xhr: xhr

            assert_response :success
            assert_item_visible visible_item, visible_assertion
            assert_item_hidden hidden_item, hidden_inventory_item
          end
        end
      end
    end
  end

  ENTITY_CASES.each do |entity_label, entity_fixture, entity_path|
    ITEM_CASES.each do |item_label, item_class|
      test "public #{entity_label} inventory item modal rejects private #{item_label} for other residents" do
        entity = public_entity(entity_fixture)
        hidden_item = create_item(item_class, privacy: "Private", name: hidden_name)
        inventory_item = attach_item(entity, hidden_item)

        sign_in @viewer
        get "#{entity_path}/#{entity.id}/inventory_items/#{inventory_item.id}.js", xhr: true

        assert_response :forbidden
        assert_item_hidden hidden_item, inventory_item
      end
    end
  end

  ITEM_CASES.each do |item_label, item_class|
    HIDDEN_FROM_PUBLIC.each do |privacy|
      test "public #{item_label} show hides #{privacy.downcase} parent item from guests" do
        parent = create_item(item_class, privacy: privacy, name: hidden_name)
        child = create_item(item_class, privacy: "Public", name: visible_name, parent: parent)

        get item_path(child)

        assert_response :success
        assert_item_visible child, :name
        assert_item_hidden parent
      end
    end
  end

  ITEM_CASES.each do |item_label, item_class|
    test "inventory item modal hides private parent #{item_label} for other residents" do
      entity = public_entity(:resident_character_one)
      parent = create_item(item_class, privacy: "Private", name: hidden_name)
      child = create_item(item_class, privacy: "Public", name: visible_name, parent: parent)
      inventory_item = attach_item(entity, child)

      sign_in @viewer
      get "/eb/resident/characters/#{entity.id}/inventory_items/#{inventory_item.id}.js", xhr: true

      assert_response :success
      assert_item_visible child, :name
      assert_item_hidden parent
    end
  end

  test "stock item index hides private stock items from signed in non admins" do
    hidden_item = create_item(Rulebuilder::StockItem, privacy: "Private", name: hidden_name)
    visible_item = create_item(Rulebuilder::StockItem, privacy: "Residents", name: visible_name)

    sign_in @viewer
    get "/rb/stock/items"

    assert_response :success
    assert_item_visible visible_item
    assert_item_hidden hidden_item
  end

  test "stock item show rejects residents stock items for guests" do
    hidden_item = create_item(Rulebuilder::StockItem, privacy: "Residents", name: hidden_name)

    get "/rb/stock/items/#{hidden_item.id}"

    assert_response :forbidden
    assert_item_hidden hidden_item
  end

  private

    def public_entity(fixture_name)
      entitybuilder_entities(fixture_name).tap do |entity|
        entity.update!(privacy: "Public", sheet_privacy: "Public")
      end
    end

    def create_item(item_class, privacy:, name:, parent: nil)
      attributes = {
        core_rules: "PFRPG",
        full_description: "#{name} full description",
        name: name,
        parent: parent,
        privacy: privacy,
        short_description: "#{name} short description"
      }
      attributes[:resident] = @resident if item_class <= Rulebuilder::ResidentItem

      item_class.create!(attributes)
    end

    def attach_item(entity, item)
      entity.inventory_items.create!(
        detail: "#{item.name} detail",
        item: item,
        quantity: 1,
        sort_order: entity.inventory_items.count + 100
      )
    end

    def item_path(item)
      return "/rb/resident/items/#{item.id}" if item.is_a?(Rulebuilder::ResidentItem)

      "/rb/stock/items/#{item.id}"
    end

    def assert_item_visible(item, assertion = :full)
      return if assertion == :none

      assert_match item.name, response.body
      assert_match item.short_description, response.body if assertion == :full
    end

    def assert_item_hidden(item, inventory_item = nil)
      assert_no_match item.name, response.body
      assert_no_match item.short_description, response.body
      assert_no_match item.full_description, response.body
      assert_no_match inventory_item.detail, response.body if inventory_item
    end

    def hidden_name
      "Hidden Item #{SecureRandom.hex(6)}"
    end

    def visible_name
      "Visible Item #{SecureRandom.hex(6)}"
    end
end
