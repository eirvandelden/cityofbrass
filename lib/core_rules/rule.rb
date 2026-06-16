module CoreRules
  module Rule

      def self.options(show_all)
        if show_all
          config = CoreRules.rulebooks
        else
          config = CoreRules.rulebooks.select{ |v| v['active'] == 'true' }
        end

        rules = []
        config.each do |core|
          hash = [core['slug'], core['rulebuilder']['rules'].collect{ |r| r['name'] }]
          rules += [hash]
        end
        return rules
      end

      def self.hash(show_all)
        if show_all
          config = CoreRules.rulebooks
        else
          config = CoreRules.rulebooks.select{ |v| v['active'] == 'true' }
        end

        rules = {}
        config.each do |core|
          hash = { core['slug'] => core['rulebuilder']['rules'].collect{ |r| r['name'] } }
          rules.merge!(hash)
        end
        return rules.to_json
      end

      def self.rule_types(core_rules)
        config = CoreRules.rulebooks.detect { |v| v['slug'] == core_rules }
        rule_types = config['rulebuilder']['rules'].collect{ |r| r['name'] }.to_a unless config.blank?
        return rule_types
      end

  end
end
