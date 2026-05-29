require "core_rules/entity"
require "core_rules/rule"
require "core_rules/seeder"

module CoreRules
  mattr_accessor :rulebooks

  def self.options(show_all)
    if show_all
      config = CoreRules.rulebooks
    else
      config = CoreRules.rulebooks.select { |v| v["active"] == "true" }
    end
    options = []
    config.each_with_index do |r, i|
      options[i] = r["name"]
    end
    options
  end

  def self.d20_system?(core_rules)
    options = rulebooks.detect { |v| v["name"] == core_rules && v["d20_system"] == "true" }
    if options.present?
      true
    else
      false
    end
  end

  def self.stock?(core_rules)
    options = rulebooks.detect { |v| v["name"] == core_rules && v["stock"] == "true" }
    if options.present?
      true
    else
      false
    end
  end

  def self.license(core_rules)
    rulebook = rulebooks.detect { |v| v["name"] == core_rules }
    license = rulebook["license"] if rulebook.present?
    license
  end

  def self.default_dice(core_rules)
    rulebook = rulebooks.detect { |v| v["name"] == core_rules }
    dice = rulebook["default_dice"] if rulebook.present?
    dice
  end
end
