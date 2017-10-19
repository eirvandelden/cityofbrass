module Quota

  FREE_USER_NPC_LIMIT = 0
  FREE_USER_CREATURE_LIMIT = 2
  FREE_USER_CHARACTER_LIMIT = 2

  FREE_USER_ADVENTURE_LIMIT = 1
  FREE_USER_DISTRICT_LIMIT = 1
  FREE_USER_CAMPAIGN_LIMIT = 1
  FREE_USER_PAGE_LIMIT = 10

  FREE_USER_RULE_LIMIT = 20
  FREE_USER_IMAGE_LIMIT = 10

  def self.over_limit?(user, type, count)
    # GET PURCHASED COUNT HERE
    purchased = 0

    case type
    when 'ResidentCharacter'
      return count > FREE_USER_CHARACTER_LIMIT + purchased
    when 'ResidentCreature'
      return count > FREE_USER_CREATURE_LIMIT + purchased
    when 'ResidentNpc'
      return count > FREE_USER_NPC_LIMIT + purchased
    when 'ResidentAdventure'
      return count > FREE_USER_ADVENTURE_LIMIT + purchased
    when 'Campaign'
      return count > FREE_USER_CAMPAIGN_LIMIT + purchased
    when 'District'
      return count > FREE_USER_DISTRICT_LIMIT + purchased
    when 'Page'
      return count > FREE_USER_PAGE_LIMIT + purchased
    when 'ResidentItem', 'ResidentRule', 'ResidentSpell'
      return count > FREE_USER_RULE_LIMIT + purchased
    when 'ResidentImage'
      return count > FREE_USER_IMAGE_LIMIT + purchased
    else
      return false
    end
  end

  def self.limit(user, type)
    # GET PURCHASED COUNT HERE
    purchased = 0

    case type
    when 'ResidentCharacter'
      return FREE_USER_CHARACTER_LIMIT + purchased
    when 'ResidentCreature'
      return FREE_USER_CREATURE_LIMIT + purchased
    when 'ResidentNpc'
      return FREE_USER_NPC_LIMIT + purchased
    when 'ResidentAdventure'
      return FREE_USER_ADVENTURE_LIMIT + purchased
    when 'ResidentCampaign'
      return FREE_USER_CAMPAIGN_LIMIT + purchased
    when 'ResidentDistrict'
      return FREE_USER_DISTRICT_LIMIT + purchased
    when 'Page'
      return FREE_USER_PAGE_LIMIT + purchased
    when 'ResidentItem', 'ResidentRule', 'ResidentSpell'
      return FREE_USER_RULE_LIMIT + purchased
    when 'ResidentImage'
      return FREE_USER_IMAGE_LIMIT + purchased
    else
      return false
    end
  end

end
