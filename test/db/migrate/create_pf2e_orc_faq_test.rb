require "test_helper"

load Rails.root.join("db/migrate/20260529000001_create_pf2e_orc_faq.rb")

class CreatePf2eOrcFaqTest < ActiveSupport::TestCase
  LICENSE_CORE_ITEMS = [ "License ORC", "License d20 OGL" ].freeze
  OGL_QUESTION = "What is the Open Game License?".freeze
  ORC_QUESTION = "What is the ORC License?".freeze

  setup do
    delete_license_faqs
  end

  teardown do
    delete_license_faqs
  end

  test "down removes the orc faq created by up" do
    migration = CreatePf2eOrcFaq.new

    migration.up
    assert_equal [ "License ORC" ], core_faq_items

    migration.down
    assert_empty core_faq_items
    assert_empty license_questions
  end

  test "down preserves a pre existing ogl faq" do
    original_faq = create_ogl_faq
    Support::CoreFaq.create!(faq: original_faq, core_item: "License d20 OGL", active: true)

    migration = CreatePf2eOrcFaq.new

    migration.up
    migration.down

    assert_equal [ [ "License d20 OGL", original_faq.id ] ], core_faq_rows
    assert_equal [ OGL_QUESTION ], license_questions
    assert Support::Faq.exists?(original_faq.id)
  end

  private

  def core_faq_items
    Support::CoreFaq.where(core_item: LICENSE_CORE_ITEMS).order(:core_item).pluck(:core_item)
  end

  def core_faq_rows
    Support::CoreFaq.where(core_item: LICENSE_CORE_ITEMS).order(:core_item).pluck(:core_item, :faq_id)
  end

  def license_questions
    Support::Faq.where(question: [ OGL_QUESTION, ORC_QUESTION ])
               .order(:question)
               .pluck(:question)
  end

  def create_ogl_faq
    Support::Faq.create!(
      topic: "Custom OGL",
      question: OGL_QUESTION,
      answer: "<p>Custom OGL answer</p>",
      active: false
    )
  end

  def delete_license_faqs
    Support::CoreFaq.where(core_item: LICENSE_CORE_ITEMS).destroy_all
    Support::Faq.left_outer_joins(:core_faqs).where(support_core_faqs: { id: nil }, question: license_questions).destroy_all
  end
end
