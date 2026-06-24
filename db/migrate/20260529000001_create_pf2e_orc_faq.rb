class CreatePf2eOrcFaq < ActiveRecord::Migration[6.1]
  CORE_ITEM = "License ORC".freeze

  # Use raw SQL to avoid triggering has_rich_text :answer on Support::Faq, which
  # references action_text_rich_texts — a table that doesn't exist yet at this point
  # in the migration sequence (it's created later, in 20260622190420).
  def up
    require Rails.root.join("lib/support/core_faq_bootstrap")

    faq_attributes = Support::CoreFaqBootstrap::LICENSE_FAQS.fetch(CORE_ITEM)
    question = faq_attributes.fetch(:question)
    now = Time.current.utc.strftime("%Y-%m-%d %H:%M:%S")

    faq_id = select_value(
      "SELECT id FROM support_faqs WHERE question = #{quote(question)} LIMIT 1"
    )

    if faq_id.nil?
      faq_id = SecureRandom.uuid
      execute(<<~SQL)
        INSERT INTO support_faqs (id, topic, question, answer, active, created_at, updated_at)
        VALUES (
          #{quote(faq_id)},
          #{quote(faq_attributes[:topic].to_s)},
          #{quote(question)},
          #{quote(faq_attributes[:answer].to_s)},
          1,
          #{quote(now)},
          #{quote(now)}
        )
      SQL
    end

    core_faq_exists = select_value(
      "SELECT id FROM support_core_faqs WHERE core_item = #{quote(CORE_ITEM)} LIMIT 1"
    )

    return if core_faq_exists

    execute(<<~SQL)
      INSERT INTO support_core_faqs (id, faq_id, core_item, active, created_at, updated_at)
      VALUES (
        #{quote(SecureRandom.uuid)},
        #{quote(faq_id)},
        #{quote(CORE_ITEM)},
        1,
        #{quote(now)},
        #{quote(now)}
      )
    SQL
  end

  def down
    faq_ids = select_values(
      "SELECT faq_id FROM support_core_faqs WHERE core_item = #{quote(CORE_ITEM)}"
    )

    execute("DELETE FROM support_core_faqs WHERE core_item = #{quote(CORE_ITEM)}")

    faq_ids.each do |faq_id|
      orphaned = select_value(
        "SELECT COUNT(*) FROM support_core_faqs WHERE faq_id = #{quote(faq_id)}"
      ).to_i.zero?
      next unless orphaned

      execute("DELETE FROM action_text_rich_texts WHERE record_type = 'Support::Faq' AND record_id = #{quote(faq_id)}") if table_exists?(:action_text_rich_texts)
      execute("DELETE FROM support_faqs WHERE id = #{quote(faq_id)}")
    end
  end
end
