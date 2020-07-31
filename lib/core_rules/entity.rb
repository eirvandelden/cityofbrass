# frozen_string_literal: false

module CoreRules
  module Entity

    def self.sheet_layout(core_rules)
      rulebook = CoreRules.rulebooks.detect { |v| v['name'] == core_rules }
      sheet = rulebook['entitybuilder']['sheet'] unless rulebook.blank?
      return sheet
    end

    def self.use_modifiers?(core_rules)
      rulebook = CoreRules.rulebooks.detect { |v| v['name'] == core_rules }
      use_modifiers = rulebook['entitybuilder']['use_modifiers'] unless rulebook.blank?
      return use_modifiers == "true" ? true : false
    end

    def self.show_core_blocks?(core_rules)
      rulebook = CoreRules.rulebooks.detect { |v| v['name'] == core_rules }
      show_core_blocks = rulebook['entitybuilder']['show_core_blocks'] unless rulebook.blank?
      return show_core_blocks == "true" ? true : false
    end

    def self.menu(core_rules)
      rulebook = CoreRules.rulebooks.detect { |v| v['name'] == core_rules }
      menu = rulebook['entitybuilder']['menu'] unless rulebook.blank?
      return menu
    end

    def self.modifier_list(core_rules)
      return menu(core_rules).select{ |v| v['add_modifiers'] == 'true' }
    end

    def self.core_skills(core_rules)
      rulebook = CoreRules.rulebooks.detect { |v| v['name'] == core_rules }
      core_skills = rulebook['entitybuilder']['core_skills'] unless rulebook.blank?
      return core_skills
    end

    def self.core_skill(core_rules, name)
      return core_skills(core_rules).select{ |v| v['name'] == name }.first
    end

    def self.default_types(core_rules, entity_type)
      config = CoreRules.rulebooks.detect { |v| v['name'] == core_rules }
      default_types = config['entitybuilder'][entity_type].keys unless config.blank?
      return default_types
    end

    def self.defaults_values(core_rules, entity_type, default_type)
      rulebook = CoreRules.rulebooks.detect { |v| v['name'] == core_rules }
      defaults = rulebook['entitybuilder'][entity_type][default_type] unless rulebook.blank?
      return defaults
    end

    # ADD RULEBOOK DEFAULTS TO NEW ENTITIES
    def self.add_defaults(entity)
      begin
        entity_type = (entity.type.include?"Creature") ? "creature" : "character"
        default_types = default_types(entity.core_rules, entity_type)

        ActiveRecord::Base.transaction do

          default_types.each do |default_type|
            records = defaults_values(entity.core_rules, entity_type, default_type)

            if default_type == 'linked_rules'
              add_linked_rules(entity, records)
            else
              records.each_with_index do |r,i|

                ar = entity.send(default_type).new
                ar.sort_order = i

                k = ActiveSupport::HashWithIndifferentAccess.new(r)
                k.each do |key, value|
                  ar[key] = value
                end
                ar.save(:validate => false)
              end
            end
          end

          add_core_skills(entity) if entity_type == "character" && entity.skills.size < 1
        end
      rescue => e
        Rails.logger.error "CoreRules::Entity.add_defaults: #{e}"
      end
    end

    def self.add_linked_rules(entity, linked_rules)
      linked_rules.each_with_index do |r,i|

        base_type = "Rulebuilder::ResidentRule"
        base_type = "Rulebuilder::StockRule" if entity.type.include?"Stock"
        base_type = "Rulebuilder::ProprietaryRule" if entity.type.include?"Proprietary"

        rule = Rulebuilder::Rule.new
        rule.type = base_type
        rule.resident_id = entity.resident_id
        rule.core_rules = entity.core_rules
        rule.rule_type = r['rule']['rule_type']
        rule.is_shared = false
        rule.name = r['rule']['name']
        rule.save(:validate => false)

        linked_rule = entity.linked_rules.new
        linked_rule.sort_order = i
        linked_rule.entity_id  = entity.id
        linked_rule.rule_id    = rule.id
        linked_rule.detail     = r['detail']
        linked_rule.save(:validate => false)
      end
    end

    def self.add_core_skills(entity)
      add_skills = core_skills(entity.core_rules)
      add_skills.each_with_index do |r,i|
        ar = entity.skills.new
        ar.sort_order    = i
        ar.name          = r['name']
        ar.ranks         = r['ranks']
        ar.ability_score = r['ability_score']
        ar.save(:validate => false)
      end
    end
  end
end
