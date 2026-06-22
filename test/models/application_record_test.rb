require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  UUID_RE = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

  def new_campaign(overrides = {})
    Campaignmanager::Campaign.new({
      resident_id: SecureRandom.uuid,
      name: "Test Campaign",
      slug: "test-#{SecureRandom.hex(6)}",
      privacy: "private"
    }.merge(overrides))
  end

  test "assigns a UUID when id is blank on create" do
    campaign = new_campaign(id: nil)
    campaign.save!(validate: false)
    assert_match UUID_RE, campaign.id
  end

  test "overwrites the uuid() sentinel with a real UUID on create" do
    campaign = new_campaign(id: "uuid()")
    campaign.save!(validate: false)
    assert_match UUID_RE, campaign.id
    assert_not_equal "uuid()", campaign.id
  end

  test "preserves an explicit UUID on create" do
    fixed_uuid = "12345678-1234-1234-1234-123456789012"
    campaign = new_campaign(id: fixed_uuid)
    campaign.save!(validate: false)
    assert_equal fixed_uuid, campaign.id
  end

  test "assigns distinct UUIDs when building associated records" do
    creature = Entitybuilder::StockCreature.new(id: SecureRandom.uuid, name: "Test Creature", core_rules: "pf2e")
    first = creature.ability_scores.build(name: "Strength", base: 1, modifier: 1)
    second = creature.ability_scores.build(name: "Dexterity", base: 2, modifier: 2)

    assert_match UUID_RE, first.id
    assert_match UUID_RE, second.id
    assert_not_equal first.id, second.id
    assert_equal [ "Strength", "Dexterity" ], creature.ability_scores.map(&:name)
  end

  test "does not assign a UUID on integer-PK models" do
    admin = Admin.new(email: "callback-test-#{SecureRandom.hex}@example.com")
    admin.save!(validate: false)
    assert_kind_of Integer, admin.id
  end
end
