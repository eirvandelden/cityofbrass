class CreatePf2eOrcFaq < ActiveRecord::Migration[6.1]
  CORE_ITEM = "License ORC".freeze

  def up
    require Rails.root.join("lib/support/core_faq_bootstrap")

    faq_attributes = Support::CoreFaqBootstrap::LICENSE_FAQS.fetch(CORE_ITEM)
    faq = Support::Faq.find_or_create_by!(question: faq_attributes.fetch(:question)) do |record|
      record.assign_attributes(faq_attributes.merge(active: true))
    end
    Support::CoreFaq.find_or_create_by!(core_item: CORE_ITEM) do |record|
      record.faq = faq
      record.active = true
    end
  end

  def down
    require Rails.root.join("lib/support/core_faq_bootstrap")

    core_faqs = Support::CoreFaq.where(core_item: CORE_ITEM)
    faq_ids = core_faqs.pluck(:faq_id)

    core_faqs.destroy_all
    Support::Faq.left_outer_joins(:core_faqs).where(id: faq_ids, support_core_faqs: { id: nil }).destroy_all
  end
end
