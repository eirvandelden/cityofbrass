module Support
  module CoreFaqsHelper
    def core_faq_list
      list = [
        'Resident New',
        'Resident Show',

        'Image Index',

        'CM Campaign Index',

        'EB Character Index',
        'EB Creature Index',
        'EB NPC Index',
        'EB Attack Tutorial',
        'EB Base Value Tutorial',
        'EB Ability Score Tutorial',
        'EB Caster Level Tutorial',
        'EB Class Level Tutorial',
        'EB Currency Tutorial',
        'EB Defense Tutorial',
        'EB Descriptor Tutorial',
        'EB Inventory Item Tutorial',
        'EB Known Ability Tutorial',
        'EB Known Feat Tutorial',
        'EB Known Spell Tutorial',
        'EB Modifier Tutorial',
        'EB Movement Tutorial',
        'EB Saving Throw Tutorial',
        'EB Skill Tutorial',
        'EB Trackable Tutorial',
        'EB Trait Tutorial',

        'RB Ability Index',
        'RB Feat Index',
        'RB Item Index',
        'RB Spell Index',

        'SB Stock Adventures',
        'SB Adventure Index',
        'SB Menu Tutorial',
        'SB Page Tutorial',

        'WB District Index',
        'WB Menu Tutorial',
        'WB Page Tutorial',

        'License d20 OGL',

        'Home World Builder',
        'Home Entity Builder',
        'Home Story Builder',
        'Home Campaign Manager',
        'Home Account'
      ]
    end

    def missing_core_items
      current_core_items = CoreFaq.pluck(:core_item)
      return core_faq_list.reject { |d| current_core_items.include?(d) }
    end
  end
end
