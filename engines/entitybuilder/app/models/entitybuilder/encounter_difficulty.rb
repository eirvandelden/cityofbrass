module Entitybuilder
  # How hard one monster is for a party, from the 4e experience budget per party level.
  class EncounterDifficulty < Data.define(:monster_experience, :party_levels)
    EASY_BELOW = 0
    STANDARD_UP_TO = 1
    HARD_UP_TO = 4

    def party_size = party_levels.size

    def party_level
      return if party_levels.empty?

      (party_levels.sum.to_f / party_size).round
    end

    # The highest level whose budget for this party fits the monster's experience, else 0.
    def encounter_level
      MonsterStats::LEVELS.select { |level| budget(level) <= monster_experience }.max || 0
    end

    def rating
      return if party_levels.empty?

      difference = encounter_level - party_level
      return :easy if difference < EASY_BELOW
      return :standard if difference <= STANDARD_UP_TO

      difference <= HARD_UP_TO ? :hard : :impossible
    end

    private

    def budget(level)
      MonsterStats::ENCOUNTER_XP_BUDGET[level - 1] * party_size
    end
  end
end
