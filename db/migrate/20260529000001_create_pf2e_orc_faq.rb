class CreatePf2eOrcFaq < ActiveRecord::Migration[6.1]
  def up
    faq_id = SecureRandom.uuid

    Support::Faq.create!(
      id:       faq_id,
      topic:    "ORC License",
      question: "What is the ORC License?",
      active:   true,
      answer:   <<~HTML.strip
        <h2>OPEN RPGCREATIVE LICENSE (ORC)</h2>

        <p>This product is published under the ORC License, located at the Library of Congress
        at TX 9-307-067, and available online at various locations including
        <a href="https://paizo.com/orclicense">paizo.com/orclicense</a>.
        All warranties are disclaimed as set forth therein.</p>

        <h3>Attribution</h3>

        <p>This product is based on the following Reserved Material:</p>
        <ul>
          <li><em>Pathfinder Player Core</em> © 2023 Paizo Inc., Authors: Logan Bonner, Jason Bulmahn, Stephen Radney-MacFarland, and Mark Seifter</li>
          <li><em>Pathfinder GM Core</em> © 2023 Paizo Inc., Authors: Logan Bonner and Mark Seifter</li>
          <li><em>Pathfinder Monster Core</em> © 2024 Paizo Inc., Authors: Logan Bonner, Jason Bulmahn, James Case, and Mark Seifter</li>
          <li><em>Pathfinder Player Core 2</em> © 2024 Paizo Inc., Authors: Logan Bonner, Jason Bulmahn, James Case, and Mark Seifter</li>
          <li><em>Pathfinder Monster Core 2</em> © 2025 Paizo Inc., Authors: Logan Bonner and Mark Seifter</li>
          <li><em>Pathfinder NPC Core</em> © 2024 Paizo Inc., Authors: Logan Bonner and Mark Seifter</li>
        </ul>

        <h3>Paizo Trademarks</h3>

        <p>Paizo, the Paizo golem logo, Pathfinder, the Pathfinder logo, Pathfinder Society,
        Starfinder, and the Starfinder logo are registered trademarks of Paizo Inc.</p>

        <h3>What You Are Permitted to Do</h3>

        <p>Under the ORC License, you are permitted to use, modify, and redistribute the
        Licensed Material, provided you comply with the license terms. See
        <a href="https://paizo.com/orclicense">paizo.com/orclicense</a> for full details.</p>

        <p><em>Note: The full ORC License text is available at the Library of Congress
        (TX 9-307-067) and at <a href="https://paizo.com/orclicense">paizo.com/orclicense</a>.
        City of Brass publishes content under this license for Pathfinder 2nd Edition (Remaster)
        per Paizo's ORC licensing terms.</em></p>
      HTML
    )

    Support::CoreFaq.create!(
      id:        SecureRandom.uuid,
      faq_id:    faq_id,
      core_item: "License ORC",
      active:    true
    )
  end

  def down
    Support::CoreFaq.find_by(core_item: "License ORC")&.destroy
    Support::Faq.joins(:core_faqs).where(support_core_faqs: { core_item: "License ORC" }).destroy_all
  end
end
