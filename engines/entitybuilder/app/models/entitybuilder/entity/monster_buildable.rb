module Entitybuilder
  class Entity
    # The 4e monster builder: level, role and group fill in the business card numbers.
    module MonsterBuildable
      extend ActiveSupport::Concern

      include Validations

      def monster_buildable?
        CoreRules::Entity.monster_builder?(core_rules)
      end

      def monster_built?
        monster_buildable? && MonsterStats::LEVELS.cover?(monster_level)
      end

      def monster_stats
        return unless monster_built?

        MonsterStats.new(level: monster_level, role: monster_role, group: monster_group,
                         defense_bonuses: monster_defense_bonuses)
      end

      def rebuild_monster(attributes)
        previous = previous_monster_stats
        transaction do
          assign_attributes(attributes)
          saved = save
          write_monster_targets(previous) if saved && monster_built?
          saved
        end
      end

      def monster_values
        stats = monster_stats
        return {} unless stats

        MonsterTarget.all.to_h { |target| [ target.key, monster_value(target, target.calculated(stats)) ] }
      end

      def reset_monster_value(key)
        target = MonsterTarget.fetch(key)
        target.write(self, target.calculated(monster_stats))
      end

      # Writes the changed values, or none when one of them is refused.
      def store_monster_values(values)
        changes = changed_monster_values(values)
        refused = changes.reject { |target, value| target.accepts?(value) }.keys
        refused.each { |target| errors.add(:base, monster_value_error(target)) }
        return false if refused.any?

        transaction { changes.each { |target, value| target.write(self, value) } }
        true
      end

      def extra_action?
        return false unless MonsterStats::PICKING_GROUPS.include?(monster_group)

        monster_extra_action.nil? ? monster_group == "Solo" : monster_extra_action
      end

      def extra_action_label
        case monster_group
        when "Solo" then I18n.t("entitybuilder.monster_builder.extra_action.solo")
        when "Elite" then I18n.t("entitybuilder.monster_builder.extra_action.elite")
        end
      end

      private

      def previous_monster_stats
        level = attribute_in_database(:monster_level)
        return unless level

        MonsterStats.new(level: level, role: attribute_in_database(:monster_role),
                         group: attribute_in_database(:monster_group),
                         defense_bonuses: parse_json_array(attribute_in_database(:monster_defense_bonuses)))
      end

      def write_monster_targets(previous)
        stats = monster_stats
        MonsterTarget.all.each do |target|
          target.write(self, target.calculated(stats)) if overwritable_monster_target?(target, previous)
        end
      end

      def overwritable_monster_target?(target, previous)
        return target.untouched_template?(self) unless previous

        !target.edited?(self, target.calculated(previous))
      end

      def changed_monster_values(values)
        values.each_pair.to_h { |key, value| [ MonsterTarget.fetch(key), value.to_s.strip ] }
              .reject { |target, value| target.stored(self).to_s == value }
      end

      def monster_value_error(target)
        I18n.t("entitybuilder.monster_builder.errors.whole_number", name: target.row_name)
      end

      def monster_value(target, calculated)
        Value.new(target: target, stored: target.stored(self), calculated: calculated,
                  edited: target.edited?(self, calculated))
      end
    end
  end
end
