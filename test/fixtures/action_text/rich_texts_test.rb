require "test_helper"

class ActionTextRichTextsFixtureTest < ActiveSupport::TestCase
  MAPPINGS = {
    Message => %w[body],
    Resident => %w[full_description],
    Rulebuilder::Rule => %w[full_description benefit normal special],
    Rulebuilder::Spell => %w[full_description],
    Rulebuilder::Item => %w[full_description],
    Storybuilder::Section => %w[content],
    Storybuilder::Adventure => %w[full_description],
    Storybuilder::Page => %w[full_description],
    Campaignmanager::Campaign => %w[full_description],
    Campaignmanager::Page => %w[full_description],
    Campaignmanager::Section => %w[content],
    Worldbuilder::District => %w[full_description],
    Worldbuilder::Page => %w[full_description],
    Worldbuilder::Section => %w[content],
    Support::Faq => %w[answer],
    Entitybuilder::Entity => %w[full_description introduction notes]
  }.freeze

  test "legacy rich text fixture columns are mirrored as Action Text fixtures" do
    MAPPINGS.each do |model, fields|
      model.unscoped.find_each do |record|
        fields.each { |field| assert_rich_text_fixture(record, field) }
      end
    end
  end

  private

  def assert_rich_text_fixture(record, field)
    legacy_body = record.read_attribute(field)
    return if legacy_body.blank?

    rich_text = ActionText::RichText.find_by(record: record, name: field)
    assert rich_text, "missing Action Text fixture for #{record.class.name}##{record.id} #{field}"
    assert_equal legacy_body, rich_text.read_attribute_before_type_cast(:body)
  end
end
