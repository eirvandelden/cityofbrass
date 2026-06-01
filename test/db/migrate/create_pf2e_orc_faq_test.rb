require "test_helper"

load Rails.root.join("db/migrate/20260529000001_create_pf2e_orc_faq.rb")

class CreatePf2eOrcFaqTest < ActiveSupport::TestCase
  LICENSE_CORE_ITEMS = [ "License ORC", "License d20 OGL" ].freeze

  setup do
    delete_license_faqs
  end

  teardown do
    delete_license_faqs
  end

  test "down removes all faqs created by up" do
    migration = CreatePf2eOrcFaq.new

    migration.up
    assert_equal LICENSE_CORE_ITEMS.sort, core_faq_items

    migration.down
    assert_empty core_faq_items
    assert_empty license_questions
  end

  private

  def core_faq_items
    Support::CoreFaq.where(core_item: LICENSE_CORE_ITEMS).order(:core_item).pluck(:core_item)
  end

  def license_questions
    Support::Faq.where(question: [ "What is the Open Game License?", "What is the ORC License?" ])
               .order(:question)
               .pluck(:question)
  end

  def delete_license_faqs
    Support::CoreFaq.where(core_item: LICENSE_CORE_ITEMS).destroy_all
    Support::Faq.left_outer_joins(:core_faqs).where(support_core_faqs: { id: nil }, question: license_questions).destroy_all
  end
end
