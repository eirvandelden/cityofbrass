require_relative "../../../../../app/models/concerns/json_array_columns"

module Rulebuilder
  class Rule < ApplicationRecord
    include KeysToRulebuilder
    include JsonArrayColumns

    has_rich_text :full_description
    has_rich_text :benefit
    has_rich_text :normal
    has_rich_text :special

    OPTIONS = [ 'Ability', 'Feat', 'Stunt' ]

    scope :order_name, -> { order(:name) }
    scope :short,      -> { select('id, type, resident_id, name, core_rules, rule_type, short_description') }
    scope :basic,      -> { select('id, type, resident_id, name, core_rules, rule_type') }
    scope :shared,     -> { where(is_shared: true) }

    json_array_column :tags, :categories

    belongs_to :parent, class_name: "Rule", optional: true

    has_many :children, -> { order(:name) }, class_name: "Rule", foreign_key: "parent_id"
    has_many :linked_rules, class_name: "Entitybuilder::LinkedRule", dependent: :destroy

    has_one :gallery_image_join,
            as: :imageable,
            class_name: "Gallery::ImageJoin",
            dependent: :destroy, inverse_of: :imageable

    has_one :gallery_image,
            through: :gallery_image_join,
            source: :image,
            class_name: "Gallery::Image"

    accepts_nested_attributes_for :gallery_image_join, allow_destroy: true

    validates :core_rules, presence: true
    validates :rule_type, presence: true

    validate  :valid_rule_type

    validates :name, presence: true, length: { maximum: 64 }
    validates :short_description, length: { maximum: 255 }
    validates :prerequisites, length: { maximum: 255 }
    validates :publisher, length: { maximum: 255 }
    validates :source, length: { maximum: 255 }
    before_save :mark_for_removal

    def tag_list
      Array(tags).join(', ')
    end

    def tag_list=(names)
      self.tags = names.split(',').map do |n|
        n = n.parameterize.tr('-', ' ').strip
      end.uniq.sort
    end

    def category_list
      Array(categories).join(', ').titleize
    end

    def category_list=(names)
      self.categories = names.split(',').map do |n|
        n = n.parameterize.tr('-', ' ').strip
      end.uniq.sort
    end

    def self.search(search)
      where("rulebuilder_rules.name like ?", "%#{search}%")
    end

    def self.core_rules_filter(core_rules_filter)
      where("rulebuilder_rules.core_rules like ?", "%#{core_rules_filter}%")
    end

    def self.rule_type_filter(rule_type_filter)
      where("rulebuilder_rules.rule_type like ?", "%#{rule_type_filter}%")
    end

    def valid_rule_type
      unless self.core_rules.present? && self.rule_type.present? && (CoreRules::Rule.rule_types(self.core_rules).include? self.rule_type)
        errors.add(:rule_type, "is not valid.")
      end
    end

    private
      def mark_for_removal
        self.gallery_image_join.mark_for_destruction if gallery_image_join && gallery_image_join.image_id.blank?
      end
  end
end
