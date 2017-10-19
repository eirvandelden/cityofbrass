require 'core_rules/rule'
require 'core_rules/entity'

module CoreRules

  mattr_accessor :rulebooks

  def self.options(show_all)
    if show_all
      config = CoreRules.rulebooks
    else
      config = CoreRules.rulebooks.select{ |v| v['active'] == 'true' }
    end
    options = []
    config.each_with_index do |r, i|
      options[i] = r['name']
    end
    return options
  end

  def self.d20_system?(core_rules)
    options = rulebooks.detect{ |v| v['name'] == core_rules && v['d20_system'] == 'true' }
    if options.present?
      return true
    else
      return false
    end
  end

  def self.stock?(core_rules)
    options = rulebooks.detect{ |v| v['name'] == core_rules && v['stock'] == 'true' }
    if options.present?
      return true
    else
      return false
    end
  end

  def self.license(core_rules)
    rulebook = rulebooks.detect { |v| v['name'] == core_rules }
    license = rulebook['license'] if rulebook.present?
    return license
  end

end
