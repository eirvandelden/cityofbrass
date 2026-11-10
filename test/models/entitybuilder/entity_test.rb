require 'test_helper'

module Entitybuilder
  class EntityTest < ActiveSupport::TestCase
    test "tag_list returns a comma separated list" do
      assert_equal "hello1, world2", entitybuilder_entities(:resident_character_one).tag_list
    end

    test "answers whether its monster group is Elite or Solo" do
      elite = entitybuilder_entities(:four_e_elite_level_3)
      solo = entitybuilder_entities(:four_e_solo_level_3)

      assert_predicate elite, :monster_elite?
      assert_not_predicate elite, :monster_solo?
      assert_predicate solo, :monster_solo?
      assert_not_predicate solo, :monster_elite?
    end

    test "answers whether a power other than the given one carries a mark" do
      elite = entitybuilder_entities(:four_e_elite_level_3)
      marked = entitybuilder_attacks(:elite_marked_power)
      plain = entitybuilder_attacks(:elite_plain_power)

      assert elite.power_marked?(:recharges_when_bloodied, except: plain)
      assert_not elite.power_marked?(:recharges_when_bloodied, except: marked)
      assert_not elite.power_marked?(:usable_at_will, except: plain)
    end

    test "an entity without the monster builder is not built and has no stats" do
      character = entitybuilder_entities(:resident_character_one)

      assert_not character.monster_built?
      assert_nil character.monster_stats
    end

    test "an entity without the monster builder has no available encounter campaign" do
      character = entitybuilder_entities(:resident_character_one)
      character.update_columns(encounter_campaign_id: campaignmanager_campaigns(:dnd4e_party_of_five).id)

      assert_not character.encounter_campaign_available?
    end

    test "can_show? returns true for Public privacy with nil user" do
      entity = entitybuilder_entities(:resident_creature_one)
      entity.privacy = 'Public'
      assert entity.can_show?(nil, false, entity.type)
    end

    test "can_show? returns false for Residents privacy with nil user" do
      entity = entitybuilder_entities(:resident_creature_one)
      entity.privacy = 'Residents'
      assert_not entity.can_show?(nil, false, entity.type)
    end

    test "can_sheet? returns true for Public sheet_privacy with nil user" do
      entity = entitybuilder_entities(:resident_creature_one)
      entity.sheet_privacy = 'Public'
      assert entity.can_sheet?(nil, false, entity.type)
    end

    test "can_sheet? returns false for Private sheet_privacy with nil user" do
      entity = entitybuilder_entities(:resident_creature_one)
      entity.sheet_privacy = 'Private'
      assert_not entity.can_sheet?(nil, false, entity.type)
    end

    test "set_privacy gives a new entity Residents and Private" do
      entity = ResidentCreature.new(privacy: nil, sheet_privacy: nil)
      entity.valid?

      assert_equal 'Residents', entity.privacy
      assert_equal 'Private', entity.sheet_privacy
    end

    test "set_privacy keeps given privacy values" do
      entity = ResidentCreature.new(privacy: 'Public', sheet_privacy: 'Public')
      entity.valid?

      assert_equal 'Public', entity.privacy
      assert_equal 'Public', entity.sheet_privacy
    end

    test "short scope includes the version label" do
      version = entitybuilder_entities(:resident_creature_full).create_version(version_label: "Level 5")

      assert_equal "Level 5", Entity.short.find(version.id).version_label
    end
  end
end
