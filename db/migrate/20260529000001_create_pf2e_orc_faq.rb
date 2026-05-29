class CreatePf2eOrcFaq < ActiveRecord::Migration[6.1]
  def up
    require Rails.root.join("lib/support/core_faq_bootstrap")

    Support::CoreFaqBootstrap.call
  end

  def down
    Support::CoreFaq.find_by(core_item: "License ORC")&.faq&.destroy
  end
end
