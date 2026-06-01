require "test_helper"
require "support/core_faq_bootstrap"

class CoreFaqBootstrapTest < ActiveSupport::TestCase
  LICENSE_CORE_ITEMS = [ "License ORC", "License d20 OGL" ].freeze
  OGL_QUESTION = "What is the Open Game License?".freeze

  setup do
    delete_license_faqs
  end

  teardown do
    delete_license_faqs
  end

  test "creates configured license FAQs" do
    assert_equal LICENSE_CORE_ITEMS.sort, configured_license_core_items

    Support::CoreFaqBootstrap.call

    core_faqs = Support::CoreFaq.where(core_item: LICENSE_CORE_ITEMS).order(:core_item)

    assert_equal LICENSE_CORE_ITEMS.sort, core_faqs.pluck(:core_item)
    assert_equal [ true, true ], core_faqs.pluck(:active)

    questions = core_faqs.map { |core_faq| core_faq.faq.question }
    assert_includes questions, "What is the Open Game License?"
    assert_includes questions, "What is the ORC License?"
  end

  test "is idempotent when run twice" do
    2.times { Support::CoreFaqBootstrap.call }

    assert_equal 2, Support::CoreFaq.where(core_item: LICENSE_CORE_ITEMS).count
    assert_equal 2, Support::Faq.joins(:core_faqs).where(support_core_faqs: { core_item: LICENSE_CORE_ITEMS }).count
  end

  test "preserves existing faq content and active flags" do
    faq = Support::Faq.create!(
      topic: "Custom OGL",
      question: OGL_QUESTION,
      answer: "<p>Custom OGL answer</p>",
      active: false
    )
    core_faq = Support::CoreFaq.create!(faq: faq, core_item: "License d20 OGL", active: false)

    Support::CoreFaqBootstrap.call

    assert_equal "Custom OGL", faq.reload.topic
    assert_equal "<p>Custom OGL answer</p>", faq.answer
    assert_not faq.active
    assert_not core_faq.reload.active
  end

  private

  def configured_license_core_items
    CoreRules.rulebooks
             .filter_map { |rulebook| rulebook.dig("license", "core_faq").presence }
             .uniq
             .sort
  end

  def delete_license_faqs
    Support::CoreFaq.where(core_item: LICENSE_CORE_ITEMS).destroy_all
    Support::Faq.left_outer_joins(:core_faqs).where(support_core_faqs: { id: nil }, question: license_questions).destroy_all
  end

  def license_questions
    [ OGL_QUESTION, "What is the ORC License?" ]
  end
end
