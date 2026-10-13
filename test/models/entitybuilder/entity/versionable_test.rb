require "test_helper"

module Entitybuilder
  class Entity
    class VersionableTest < ActiveSupport::TestCase
      setup do
        @monster = entitybuilder_entities(:resident_creature_full)
      end

      test "refuses a blank version label" do
        version = @monster.create_version(version_label: "")

        assert_not version.persisted?
        assert_predicate version.errors[:version_label], :any?
      end

      test "refuses a label over 64 characters" do
        version = @monster.create_version(version_label: "x" * 65)

        assert_not version.persisted?
        assert_predicate version.errors[:version_label], :any?
      end

      test "every entity association is listed as copied or skipped" do
        listed = Versionable::COPIED_ASSOCIATIONS + Versionable::SKIPPED_ASSOCIATIONS

        [ ResidentCreature, ResidentNpc ].each do |model|
          actual = model.reflect_on_all_associations.select { |r| r.macro.in?(%i[has_many has_one]) }.map(&:name)

          assert_empty actual - listed, model.name
        end
      end

      test "copies every child association with fresh ids" do
        version = @monster.create_version(version_label: "Level 10")

        Versionable::PLAIN_CHILDREN.each do |name|
          copies = version.public_send(name)

          assert_equal @monster.public_send(name).size, copies.size, name
          assert_operator copies.size, :>, 0, name
          assert_empty copies.map(&:id) & @monster.public_send(name).map(&:id), name
        end
        assert_equal 2, version.linked_rules.size
      end

      test "remaps modifiers to the copied rows" do
        version = @monster.create_version(version_label: "Level 10")
        modifier = version.modifiers.sole

        assert_equal version.ability_scores.first.id, modifier.modifierable_id
        assert_equal "Rage", modifier.category
      end

      test "skips a modifier whose target was not copied" do
        version = @monster.create_version(version_label: "Level 10")

        assert_equal [ "Rage" ], version.modifiers.map(&:category)
      end

      test "copies rich text and the gallery image" do
        version = @monster.create_version(version_label: "Level 10")

        assert_includes version.full_description.to_s, "Orcs smash things"
        assert_equal @monster.gallery_image_join.image_id, version.gallery_image_join.image_id
        assert_not_equal @monster.gallery_image_join.id, version.gallery_image_join.id
      end

      test "does not leave empty rich text behind on the parent" do
        @monster.create_version(version_label: "Level 10")
        @monster.save!

        assert_not ActionText::RichText.exists?(record: @monster, name: "notes")
      end

      test "lists versions in natural label order" do
        [ "Level 10", "level 5", "Elite", "Level 25" ].each { |label| @monster.create_version(version_label: label) }

        labels = @monster.versions_visible_to(users(:dan), false).map(&:version_label)

        assert_equal [ "Elite", "level 5", "Level 10", "Level 25" ], labels
      end

      test "breaks natural order ties by the exact label" do
        [ "level 5", "Level 5", "Level 05" ].each { |label| @monster.create_version(version_label: label) }

        labels = @monster.versions_visible_to(users(:dan), false).map(&:version_label)

        assert_equal [ "Level 05", "Level 5", "level 5" ], labels
      end

      test "lists only the versions a viewer may see" do
        @monster.create_version(version_label: "Level 5")
        @monster.create_version(version_label: "Level 10").update_columns(privacy: "Private")

        visible_to_owner = @monster.versions_visible_to(users(:dan), false)
        visible_to_other = Entity.find(@monster.id).versions_visible_to(users(:lucas), false)

        assert_equal [ "Level 5", "Level 10" ], visible_to_owner.map(&:version_label)
        assert_equal [ "Level 5" ], visible_to_other.map(&:version_label)
      end

      test "shows the parent only to a viewer who may see it" do
        parent = entitybuilder_entities(:resident_creature_private)
        version = parent.create_version(version_label: "Level 3")

        assert_equal parent, version.parent_visible_to(users(:dan), false)
        assert_nil version.parent_visible_to(users(:lucas), false)
        assert_nil @monster.parent_visible_to(users(:dan), false)
      end

      test "copies notables through notableable only" do
        version = @monster.create_version(version_label: "Level 10")

        assert_equal [ "Ally" ], version.notables.map(&:name)
        assert_equal [ "Ally" ], @monster.notables.map(&:name)
      end

      test "does not copy the campaign join or notables pointing at the monster" do
        version = @monster.create_version(version_label: "Level 10")

        assert_nil version.campaign_join
        assert_empty version.eb_notables
        assert_equal 1, @monster.eb_notables.size
      end

      test "shares a shared linked rule" do
        version = @monster.create_version(version_label: "Level 10")

        assert_includes version.rules.map(&:id), rulebuilder_rules(:resident_one).id
      end

      test "gives the version its own copy of an unshared linked rule" do
        version = @monster.create_version(version_label: "Level 10")
        copy = version.rules.find { |rule| rule.name == "Ferocity" }

        assert_not_equal rulebuilder_rules(:monster_unshared).id, copy.id
        assert_includes copy.full_description.to_s, "Unshared rule text"
        assert_equal [ "orc" ], copy.tags
        assert_equal [ "One" ], copy.categories
      end

      test "destroying the parent keeps the version's linked rules" do
        version = @monster.create_version(version_label: "Level 10")

        @monster.destroy

        assert_equal 2, Entity.find(version.id).rules.count
        assert Rulebuilder::Rule.exists?(version.rules.find { |rule| rule.name == "Ferocity" }.id)
      end

      test "editing the version's unshared rule leaves the parent's rule unchanged" do
        version = @monster.create_version(version_label: "Level 10")
        version.rules.find { |rule| rule.name == "Ferocity" }.update!(name: "Rage")

        assert_equal "Ferocity", rulebuilder_rules(:monster_unshared).reload.name
      end

      test "keeps resident, name, type and privacy" do
        @monster.update!(privacy: "Public", sheet_privacy: "Friends")
        version = @monster.create_version(version_label: "Level 10")

        assert_equal @monster.resident_id, version.resident_id
        assert_equal @monster.name, version.name
        assert_equal @monster.type, version.type
        assert_equal "Public", version.privacy
        assert_equal "Friends", version.sheet_privacy
        assert_equal @monster, version.parent
      end

      test "links a version of a version to the root parent" do
        first = @monster.create_version(version_label: "Level 10")
        second = first.create_version(version_label: "Level 15")

        assert_equal @monster, second.parent
        assert_equal [ "Level 10", "Level 15" ], @monster.versions.map(&:version_label).sort
      end

      test "destroying the parent keeps its versions" do
        version = @monster.create_version(version_label: "Level 10")

        @monster.destroy

        assert_nil Entity.find(version.id).parent_id
      end

      test "rebuilds a built copy at the given level" do
        built = entitybuilder_entities(:four_e_creature_built)

        version = built.create_version(version_label: "Level 10", monster_level: 10)

        assert_predicate version, :persisted?
        assert_equal 10, version.monster_level
        assert_equal 22, version.defenses.find_by(name: "Fortitude").bonus
        assert_equal 23, version.defenses.find_by(name: "Armor Class").bonus
        assert_predicate version.monster_values[:armor_class], :needs_manual_revision?
        assert_equal "10", version.descriptors.find_by(name: "Level").description
        assert_equal 5, built.reload.monster_level
        assert_equal 17, built.defenses.find_by(name: "Fortitude").bonus
      end

      test "ignores a level for an unbuilt copy" do
        unbuilt = entitybuilder_entities(:four_e_creature_unbuilt)

        version = unbuilt.create_version(version_label: "Level 10", monster_level: 10)

        assert_predicate version, :persisted?
        assert_nil version.monster_level
        assert_equal 14, version.defenses.find_by(name: "Armor Class").base
        assert_nil version.defenses.find_by(name: "Armor Class").bonus
      end

      test "copies an npc" do
        npc = entitybuilder_entities(:resident_npc_one)
        version = npc.create_version(version_label: "Veteran")

        assert_predicate version, :persisted?
        assert_kind_of ResidentNpc, version
      end
    end
  end
end
