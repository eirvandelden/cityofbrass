module Support
  # Ensures configured license FAQ records exist for license-linked game systems.
  class CoreFaqBootstrap
    LICENSE_FAQS = {
      "License d20 OGL" => {
        topic: "Open Game License",
        question: "What is the Open Game License?",
        answer: <<~HTML.strip
          <h2>OPEN GAME LICENSE</h2>

          <p>This product includes Open Game Content used under the Open Game License 1.0a.</p>

          <p>The Open Game License allows publishers to use and share designated Open Game Content,
          provided they follow the license terms and preserve required notices and attributions.</p>

          <p>See the Open Game License 1.0a text included with the relevant product for the full
          terms, conditions, and declarations of Open Game Content and Product Identity.</p>
        HTML
      },
      "License ORC" => {
        topic: "ORC License",
        question: "What is the ORC License?",
        answer: <<~HTML.strip
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
      }
    }.freeze

    class << self
      def call
        configured_license_core_items.each { |core_item| upsert_license_faq(core_item) }
      end

      private

      def configured_license_core_items
        CoreRules.rulebooks.filter_map { |rulebook| rulebook.dig("license", "core_faq").presence }.uniq
      end

      def upsert_license_faq(core_item)
        faq = Support::Faq.find_or_initialize_by(question: faq_attributes(core_item).fetch(:question))
        create_faq!(faq, core_item) if faq.new_record?

        core_faq = Support::CoreFaq.find_or_initialize_by(core_item: core_item)
        create_core_faq!(core_faq, faq) if core_faq.new_record?
      end

      def faq_attributes(core_item)
        LICENSE_FAQS.fetch(core_item)
      end

      def create_faq!(faq, core_item)
        faq.assign_attributes(faq_attributes(core_item).merge(active: true))
        faq.save!
      end

      def create_core_faq!(core_faq, faq)
        core_faq.assign_attributes(faq: faq, active: true)
        core_faq.save!
      end
    end
  end
end
