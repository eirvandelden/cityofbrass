module Entitybuilder
  # One number the monster builder writes into an existing child row of the entity.
  class MonsterTarget < Data.define(:key, :association, :row_name, :field, :value_method, :integer)
    FIRST_ROWS = %i[armor_class hit_points].freeze
    TEMPLATE_FIELDS = {
      defenses: %w[base bonus misc_modifier ability_score], movements: %w[base bonus misc_modifier ability_score],
      trackables: %w[maximum], descriptors: %w[description], saving_throws: %w[bonus]
    }.freeze
    ROWS = [
      [ :armor_class, :defenses, "Armor Class", :bonus, :armor_class, true ],
      [ :fortitude, :defenses, "Fortitude", :bonus, :fortitude, true ],
      [ :reflex, :defenses, "Reflex", :bonus, :reflex, true ],
      [ :will, :defenses, "Will", :bonus, :will, true ],
      [ :initiative, :movements, "Initiative", :base, :initiative_base, true ],
      [ :hit_points, :trackables, "Hit Points", :maximum, :hit_points, true ],
      [ :action_points, :trackables, "Action Points", :maximum, :action_points, true ],
      [ :saving_throws, :saving_throws, "Saving Throws", :bonus, :saving_throw_bonus, true ],
      [ :level, :descriptors, "Level", :description, :level, false ],
      [ :role, :descriptors, "Role", :description, :role_label, false ],
      [ :experience, :descriptors, "Experience", :description, :experience, false ]
    ].freeze
    TARGETS = ROWS.map { |row| new(*row) }.index_by(&:key).freeze

    def self.all = TARGETS.values

    def self.fetch(key) = TARGETS.fetch(key.to_sym)

    def calculated(stats) = cast(stats.public_send(value_method))

    def stored(entity)
      row = row_for(entity)
      return missing_value unless row

      cast(row[field])
    end

    def edited?(entity, calculated)
      return true if key == :initiative && row_for(entity)&.bonus.present?

      stored(entity) != cast(calculated)
    end

    def untouched_template?(entity)
      row = row_for(entity)
      return true unless row

      template = template_row(entity)
      template.present? && TEMPLATE_FIELDS[association].all? { |name| row[name].to_s == template[name].to_s }
    end

    def write(entity, value)
      value = cast(value)
      return remove_row(entity) if key == :saving_throws && value.to_i.zero?

      row = row_for(entity) || build_row(entity)
      assign(row, value)
      row.save!
      entity.public_send(association).reset
    end

    private

    def cast(value) = integer ? value&.to_i : value&.to_s

    def row_for(entity) = entity.public_send(association).find_by(name: row_name)

    def missing_value = key == :saving_throws ? 0 : nil

    def template_row(entity)
      type = entity.type.include?("Creature") ? "creature" : "character"
      rows = CoreRules::Entity.defaults_values(entity.core_rules, type, association.to_s)
      Array(rows).detect { |template| template["name"] == row_name }
    end

    def remove_row(entity)
      row_for(entity)&.destroy!
      entity.public_send(association).reset
    end

    def build_row(entity)
      entity.public_send(association).build(name: row_name, sort_order: new_sort_order(entity), **new_row_defaults)
    end

    def new_sort_order(entity)
      orders = entity.public_send(association).reload.filter_map(&:sort_order)
      FIRST_ROWS.include?(key) ? (orders.min || 1) - 1 : (orders.max || -1) + 1
    end

    def new_row_defaults
      return { base: 0 } if association == :defenses

      key == :initiative ? { ability_score: "Dexterity" } : {}
    end

    def assign(row, value)
      follow_current(row, value) if key == :hit_points
      row[field] = value
    end

    # Wounds tracked on the sheet survive a rebuild.
    def follow_current(row, value)
      row[:current] = value if row.current.nil? || row.current == row.maximum
    end
  end
end
