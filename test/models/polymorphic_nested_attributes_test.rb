require "test_helper"

class PolymorphicNestedAttributesTest < ActiveSupport::TestCase
  test "parent records accept nested polymorphic children before save" do
    records = [
      storybuilder_adventure_with(:features_attributes, feature_attributes),
      storybuilder_adventure_with(:sections_attributes, section_attributes),
      storybuilder_adventure_with(:menu_items_attributes, menu_item_attributes),
      storybuilder_page_with(:features_attributes, feature_attributes),
      storybuilder_page_with(:sections_attributes, section_attributes),
      campaignmanager_campaign_with(:features_attributes, feature_attributes),
      campaignmanager_campaign_with(:sections_attributes, section_attributes),
      campaignmanager_campaign_with(:menu_items_attributes, menu_item_attributes),
      campaignmanager_page_with(:features_attributes, feature_attributes),
      campaignmanager_page_with(:sections_attributes, section_attributes),
      worldbuilder_district_with(:features_attributes, feature_attributes),
      worldbuilder_district_with(:sections_attributes, section_attributes),
      worldbuilder_district_with(:menu_items_attributes, menu_item_attributes),
      worldbuilder_page_with(:features_attributes, feature_attributes),
      worldbuilder_page_with(:sections_attributes, section_attributes)
    ]

    records.each do |record|
      assert record.valid?, "#{record.class.name} was invalid: #{record.errors.full_messages.to_sentence}"
    end
  end

  private

  def storybuilder_adventure_with(association, attributes)
    Storybuilder::ResidentAdventure.new(storybuilder_adventure_attributes.merge(association => [ attributes ]))
  end

  def storybuilder_page_with(association, attributes)
    Storybuilder::Page.new(storybuilder_page_attributes.merge(association => [ attributes ]))
  end

  def campaignmanager_campaign_with(association, attributes)
    Campaignmanager::Campaign.new(campaignmanager_campaign_attributes.merge(association => [ attributes ]))
  end

  def campaignmanager_page_with(association, attributes)
    Campaignmanager::AdventureLog.new(campaignmanager_page_attributes.merge(association => [ attributes ]))
  end

  def worldbuilder_district_with(association, attributes)
    Worldbuilder::District.new(worldbuilder_district_attributes.merge(association => [ attributes ]))
  end

  def worldbuilder_page_with(association, attributes)
    Worldbuilder::Religion.new(worldbuilder_page_attributes.merge(association => [ attributes ]))
  end

  def storybuilder_adventure_attributes
    { name: "Nested adventure", privacy: "Private", resident: residents(:razune) }
  end

  def storybuilder_page_attributes
    { name: "Nested page", privacy: "Private", adventure: storybuilder_adventures(:resident_one) }
  end

  def campaignmanager_campaign_attributes
    { name: "Nested campaign", privacy: "Private", resident: residents(:razune) }
  end

  def campaignmanager_page_attributes
    { name: "Nested campaign page", privacy: "Private", campaign: campaignmanager_campaigns(:resident_one) }
  end

  def worldbuilder_district_attributes
    { name: "Nested district", privacy: "Private", resident: residents(:razune) }
  end

  def worldbuilder_page_attributes
    { name: "Nested world page", district: worldbuilder_districts(:district_one) }
  end

  def feature_attributes
    { feature_label: "Feature", feature_type: "text" }
  end

  def section_attributes
    { section_style: "default", section_type: "paragraph" }
  end

  def menu_item_attributes
    { item_label: "Menu item" }
  end
end
