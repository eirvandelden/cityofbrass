module Entitybuilder
  class Entity
    # Copies a monster, with its child rows, into a new version.
    module VersionCopy
      extend ActiveSupport::Concern

      RICH_TEXTS = %i[full_description introduction notes].freeze
      RULE_RICH_TEXTS = %i[full_description benefit normal special].freeze

      def create_version(version_label:, monster_level: nil)
        version = build_version(version_label)
        return version unless valid_version?(version, monster_level)

        transaction do
          version.save!
          copy_children_into(version)
          rebuild_version_monster(version, monster_level)
        end
        version
      end

      private
        def build_version(version_label)
          dup.tap do |version|
            version.parent = parent || self
            version.version_label = version_label
            copy_rich_text(self, version, RICH_TEXTS)
            version.gallery_image_join = gallery_image_join.dup if gallery_image_join
          end
        end

        def copy_children_into(version)
          copied = {}
          Versionable::PLAIN_CHILDREN.each { |name| copied.merge!(copy_rows(public_send(name), version)) }
          copied.merge!(copy_rows(linked_rules, version) { |row| row.rule_id = rule_for_copy(row.rule).id })
          copy_notables(version)
          copy_modifiers(version, copied)
        end

        def copy_rows(rows, version)
          rows.to_h do |row|
            copy = row.dup
            copy.entity_id = version.id
            yield copy if block_given?
            copy.save!(validate: false)
            [ [ row.class.polymorphic_name, row.id ], copy.id ]
          end
        end

        def copy_notables(version)
          notables.each do |notable|
            copy = notable.dup
            copy.notableable_id = version.id
            copy.save!(validate: false)
          end
        end

        def copy_modifiers(version, copied)
          modifiers.each do |modifier|
            target_id = copied[[ modifier.modifierable_type, modifier.modifierable_id ]]
            next unless target_id

            copy = modifier.dup
            copy.assign_attributes(entity_id: version.id, modifierable_id: target_id)
            copy.save!(validate: false)
          end
        end

        # An unshared rule belongs to one monster: LinkedRule destroys it with the join row.
        def rule_for_copy(rule)
          return rule if rule.is_shared

          rule.dup.tap do |copy|
            copy_rich_text(rule, copy, RULE_RICH_TEXTS)
            copy.gallery_image_join = rule.gallery_image_join.dup if rule.gallery_image_join
            copy.save!(validate: false)
          end
        end

        def copy_rich_text(source, target, names)
          names.each do |name|
            body = source.public_send("rich_text_#{name}")&.body
            target.public_send("#{name}=", body) if body
          end
        end

        # Checks the new level before anything is saved. A refused version keeps that level for the form.
        def valid_version?(version, monster_level)
          return version.valid? unless rebuild_version?(version, monster_level)

          copied_level = version.monster_level
          version.monster_level = monster_level
          version.valid?.tap { |valid| version.monster_level = copied_level if valid }
        end

        def rebuild_version?(version, monster_level)
          monster_level.present? && version.monster_built?
        end

        # A built copy at another level recalculates its unedited numbers; edited ones stay marked.
        def rebuild_version_monster(version, monster_level)
          return unless rebuild_version?(version, monster_level)

          version.rebuild_monster(monster_level: monster_level) || raise(ActiveRecord::RecordInvalid, version)
        end
    end
  end
end
