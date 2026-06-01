class CreatePf2eOrcFaq < ActiveRecord::Migration[6.1]
  def up
    require Rails.root.join("lib/support/core_faq_bootstrap")

    Support::CoreFaqBootstrap.call
  end

  def down
    require Rails.root.join("lib/support/core_faq_bootstrap")

    core_faqs = Support::CoreFaq.where(core_item: Support::CoreFaqBootstrap::LICENSE_FAQS.keys)
    faq_ids = core_faqs.pluck(:faq_id)

    core_faqs.destroy_all
    Support::Faq.left_outer_joins(:core_faqs).where(id: faq_ids, support_core_faqs: { id: nil }).destroy_all
  end
end
