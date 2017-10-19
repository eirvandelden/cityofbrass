module Entitybuilder
  class LinkedRule < ApplicationRecord
    belongs_to :entity
    belongs_to :rule, :class_name => "Rulebuilder::Rule"

    has_many :modifiers, -> { order(:sort_order) }, :as => :modifierable, :dependent => :destroy
    accepts_nested_attributes_for :modifiers, :allow_destroy => true
    accepts_nested_attributes_for :rule

    validates_presence_of :rule
    validates :detail, length: { maximum: 40 }

    after_destroy :destroy_rule

    def name
      return rule.name
    end

    def rule_type
      return rule.rule_type
    end

    def self.core_rules_filter(core_rules_filter)
      where("rulebuilder_rules.core_rules ilike ?", "%#{core_rules_filter}%")
    end

    def self.rule_type_filter(rule_type_filter)
      where("rulebuilder_rules.rule_type ilike ?", "%#{rule_type_filter}%")
    end

    private
      def destroy_rule
        self.rule.destroy unless self.rule.is_shared
      end

  end
end
