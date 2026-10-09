module Entitybuilder
  class Entity
    # A resident monster can have copies ("versions") linked to one root parent.
    module Versionable
      extend ActiveSupport::Concern

      PLAIN_CHILDREN = %i[
        descriptors ability_scores movements class_levels caster_levels base_values skills trackables
        attacks defenses saving_throws currencies known_spells inventory_items
      ].freeze
      COPIED_ASSOCIATIONS = (PLAIN_CHILDREN + %i[
        linked_rules modifiers notables gallery_image_join gallery_image
        rich_text_full_description rich_text_introduction rich_text_notes
        rules spells items
      ]).freeze
      SKIPPED_ASSOCIATIONS = %i[
        campaign_join campaign district prepared_known_spells prepared_spells entities
        eb_notables sb_notables cm_notables ap_notables versions user
      ].freeze
      RICH_TEXTS = %i[full_description introduction notes].freeze
      RULE_RICH_TEXTS = %i[full_description benefit normal special].freeze

      included do
        belongs_to :parent, class_name: "Entitybuilder::Entity", optional: true
        has_many :versions, -> { order(:version_label) }, class_name: "Entitybuilder::Entity",
                 foreign_key: :parent_id, dependent: :nullify

        validates :version_label, presence: true, if: :parent_id?
        validates :version_label, length: { maximum: 64 }
      end

      def create_version(version_label:)
        version = build_version(version_label)
        return version unless version.valid?

        transaction do
          version.save!
          copy_children_into(version)
        end
        version
      end

      def parent_visible_to(current_user, is_admin)
        parent if parent&.can_show?(current_user, is_admin, parent.type.demodulize)
      end

      def versions_visible_to(current_user, is_admin)
        versions.select { |version| version.can_show?(current_user, is_admin, version.type.demodulize) }
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
          PLAIN_CHILDREN.each { |name| copied.merge!(copy_rows(public_send(name), version)) }
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
    end
  end
end
