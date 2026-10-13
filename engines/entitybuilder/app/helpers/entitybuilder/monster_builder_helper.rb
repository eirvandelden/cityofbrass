module Entitybuilder
  module MonsterBuilderHelper
    def monster_role_options
      MonsterStats::ROLES.map { |role| [ monster_term(:roles, role), role ] }
    end

    def monster_group_options
      MonsterStats::GROUPS.map { |group| [ monster_term(:groups, group), group ] }
    end

    def monster_defense_options
      MonsterStats::DEFENSES.map { |defense| [ monster_term(:defenses, defense), defense ] }
    end

    def monster_role_label(entity)
      role = monster_term(:roles, entity.monster_role)
      entity.monster_group == "Standard" ? role : "#{monster_term(:groups, entity.monster_group)} #{role}"
    end

    private
      def monster_term(kind, term)
        t("entitybuilder.monster_builder.#{kind}.#{term.downcase}")
      end
  end
end
