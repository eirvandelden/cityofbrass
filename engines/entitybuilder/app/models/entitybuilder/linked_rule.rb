module Entitybuilder
  class LinkedRule < ApplicationRecord
    belongs_to :entity, inverse_of: :linked_rules
    belongs_to :rule, class_name: "Rulebuilder::Rule"

    has_many :modifiers, -> { order(:sort_order) }, as: :modifierable, dependent: :destroy, inverse_of: :modifierable
    accepts_nested_attributes_for :modifiers, allow_destroy: true
    accepts_nested_attributes_for :rule

    validates_presence_of :rule
    validates :detail, length: { maximum: 40 }

    after_destroy :destroy_rule

    def name
      rule.name
    end

    def rule_type
      rule.rule_type
    end

    def self.core_rules_filter(core_rules_filter)
      where("rulebuilder_rules.core_rules like ?", "%#{core_rules_filter}%")
    end

    def self.rule_type_filter(rule_type_filter)
      where("rulebuilder_rules.rule_type like ?", "%#{rule_type_filter}%")
    end

    private
      def destroy_rule
        self.rule.destroy unless self.rule.is_shared
      end
  end
end
