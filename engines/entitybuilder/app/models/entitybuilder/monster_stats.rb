module Entitybuilder
  # The 4e "Monster Manual 3 on a business card" numbers. See docs/4e-business-card.md
  # and docs/4e-xp-tables.md.
  class MonsterStats < Data.define(:level, :role, :group, :defense_bonuses)
    ROLES = %w[Artillery Brute Controller Lurker Skirmisher Soldier].freeze
    GROUPS = %w[Minion Standard Elite Solo].freeze
    DEFENSES = %w[Fortitude Reflex Will].freeze
    PICKING_GROUPS = %w[Elite Solo].freeze

    ARMOR_CLASS_ROLE = Hash.new(0).merge("Soldier" => 2, "Brute" => -2, "Artillery" => -2).freeze
    GROUP_BONUS = { "Elite" => 2, "Solo" => 2 }.freeze
    HIT_POINTS_ROLE = Hash.new([ 24, 8 ]).merge("Brute" => [ 26, 10 ], "Artillery" => [ 21, 6 ],
                                                 "Lurker" => [ 21, 6 ]).freeze
    HIT_POINT_FACTOR = { "Elite" => 2, "Solo" => 4 }.freeze
    SAVING_THROWS = { "Elite" => 2, "Solo" => 5 }.freeze
    ACTION_POINTS = { "Elite" => 1, "Solo" => 2 }.freeze
    INITIATIVE_ROLE = Hash.new(0).merge("Skirmisher" => 2, "Soldier" => 2, "Lurker" => 3).freeze
    XP_FACTOR = { "Elite" => 2, "Solo" => 5 }.freeze

    STANDARD_XP = [
      100, 125, 150, 175, 200, 250, 300, 350, 400, 500, 600, 700, 800, 1000, 1200, 1400, 1600, 2000,
      2400, 2800, 3200, 4150, 5100, 6050, 7000, 9000, 11_000, 13_000, 15_000, 19_000, 23_000, 27_000,
      31_000, 39_000, 47_000, 55_000, 63_000, 79_000, 95_000, 111_000
    ].freeze
    MINION_XP = [
      25, 31, 38, 44, 50, 63, 75, 88, 100, 125, 150, 175, 200, 250, 300, 350, 400, 500, 600, 700, 800,
      1038, 1275, 1513, 1750, 2250, 2750, 3250, 3750, 4750, 5750, 6750, 7750, 9750, 11_750, 13_750,
      15_750, 19_750, 23_750, 27_750
    ].freeze
    ENCOUNTER_XP_BUDGET = STANDARD_XP

    USAGE_FACTOR = { at_will: 1r, encounter: 5r / 4 }.freeze

    def armor_class
      14 + level + ARMOR_CLASS_ROLE[role] + GROUP_BONUS.fetch(group, 0)
    end

    def fortitude = defense("Fortitude")
    def reflex = defense("Reflex")
    def will = defense("Will")

    def attack_bonus = 5 + level

    def average_damage = 8 + level

    def hit_points
      return 1 if group == "Minion"

      base, per_level = HIT_POINTS_ROLE[role]
      (base + per_level * level) * HIT_POINT_FACTOR.fetch(group, 1)
    end

    def saving_throw_bonus = SAVING_THROWS.fetch(group, 0)

    def action_points = ACTION_POINTS.fetch(group, 0)

    def initiative_base = level / 2 + INITIATIVE_ROLE[role]

    def experience
      return MINION_XP[level - 1] if group == "Minion"

      STANDARD_XP[level - 1] * XP_FACTOR.fetch(group, 1)
    end

    def role_label
      group == "Standard" ? role : "#{group} #{role}"
    end

    def power_damage(usage:, multi_target:)
      factor = USAGE_FACTOR.fetch(usage) * (multi_target ? 3r / 4 : 1r)
      factor *= 5r / 4 if role == "Brute"
      factor *= 1r / 2 if group == "Minion"
      (average_damage * factor).floor
    end

    private

    def defense(name)
      bonus = PICKING_GROUPS.include?(group) && Array(defense_bonuses).include?(name) ? 2 : 0
      12 + level + bonus
    end
  end
end
