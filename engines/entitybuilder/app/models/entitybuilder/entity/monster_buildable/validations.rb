module Entitybuilder
  class Entity
    module MonsterBuildable
      # Builder inputs are checked only when one of them changes, so unrelated updates never fail on them.
      module Validations
        extend ActiveSupport::Concern

        INPUTS = %i[monster_level monster_role monster_group monster_defense_bonuses monster_extra_action].freeze

        included do
          normalizes :monster_role, :monster_group, with: ->(value) { value.presence }

          before_validation :clear_monster_defense_bonuses, if: :monster_inputs_changed?
          validate :validate_monster_inputs, if: :monster_inputs_changed?
        end

        private

        def monster_inputs_changed?
          INPUTS.any? { |input| will_save_change_to_attribute?(input) }
        end

        def clear_monster_defense_bonuses
          self.monster_defense_bonuses = [] unless MonsterStats::PICKING_GROUPS.include?(monster_group)
        end

        def validate_monster_inputs
          add_monster_error(:base, "unavailable") unless monster_buildable?
          add_monster_error(:base, "incomplete") unless monster_inputs_complete_or_blank?
          add_monster_error(:monster_level, "level") unless monster_level.nil? || MonsterStats::LEVELS.cover?(monster_level)
          add_monster_error(:monster_role, "role") unless monster_role.nil? || MonsterStats::ROLES.include?(monster_role)
          add_monster_error(:monster_group, "group") unless monster_group.nil? || MonsterStats::GROUPS.include?(monster_group)
          add_monster_error(:monster_defense_bonuses, "picks") unless valid_monster_defense_bonuses?
        end

        def monster_inputs_complete_or_blank?
          [ monster_level, monster_role, monster_group ].map(&:blank?).uniq.size == 1
        end

        def valid_monster_defense_bonuses?
          picks = monster_defense_bonuses
          picks.size <= 2 && (picks - MonsterStats::DEFENSES).empty?
        end

        def add_monster_error(attribute, kind)
          errors.add(attribute, I18n.t("entitybuilder.monster_builder.errors.#{kind}"))
        end
      end
    end
  end
end
