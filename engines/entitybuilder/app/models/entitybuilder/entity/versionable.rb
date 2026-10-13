module Entitybuilder
  class Entity
    # A resident monster can have copies ("versions") linked to one root parent.
    module Versionable
      extend ActiveSupport::Concern

      include VersionCopy

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

      included do
        belongs_to :parent, class_name: "Entitybuilder::Entity", optional: true
        has_many :versions, class_name: "Entitybuilder::Entity", foreign_key: :parent_id, dependent: :nullify

        validates :version_label, presence: true, if: :parent_id?
        validates :version_label, length: { maximum: 64 }
      end

      def parent_visible_to(current_user, is_admin)
        parent if parent&.can_show?(current_user, is_admin, parent.type.demodulize)
      end

      def versions_visible_to(current_user, is_admin)
        versions
          .select { |version| version.can_show?(current_user, is_admin, version.type.demodulize) }
          .sort_by { |version| [ natural_sort_key(version.version_label), version.version_label.to_s, version.id ] }
      end

      private
        # "Level 5" sorts before "Level 10": digit runs compare as numbers, the rest case-insensitively.
        # Callers break ties by the exact label, because sort_by is not stable.
        def natural_sort_key(label)
          label.to_s.split(/(\d+)/).map { |part| part.match?(/\A\d+\z/) ? [ 0, part.to_i ] : [ 1, part.downcase ] }
        end
    end
  end
end
