require "core_rules/rulebook"
require "core_rules/entity"
require "core_rules/rule"
require "core_rules/seeder"

module CoreRules
  mattr_accessor :rulebooks

  def self.all(show_all = true)
    config = show_all ? rulebooks : rulebooks.select { |v| v["active"] == "true" }
    config.map do |v|
      Rulebook.new(
        slug:         v["slug"],
        name:         v["name"],
        active:       v["active"],
        stock:        v["stock"],
        d20_system:   v["d20_system"],
        default_dice: v["default_dice"],
        license:      v["license"]
      )
    end
  end

  def self.find(slug)
    all.detect { |r| r.slug == slug }
  end

  def self.display_name(slug)
    rulebook = rulebooks.detect { |v| v["slug"] == slug }
    rulebook["name"] if rulebook.present?
  end

  def self.options(show_all)
    config = show_all ? rulebooks : rulebooks.select { |v| v["active"] == "true" }
    config.map { |r| [ r["name"], r["slug"] ] }
  end

  def self.d20_system?(slug)
    rulebooks.any? { |v| v["slug"] == slug && v["d20_system"] == "true" }
  end

  def self.stock?(slug)
    rulebooks.any? { |v| v["slug"] == slug && v["stock"] == "true" }
  end

  def self.license(slug)
    rulebook = rulebooks.detect { |v| v["slug"] == slug }
    rulebook["license"] if rulebook.present?
  end

  def self.default_dice(slug)
    rulebook = rulebooks.detect { |v| v["slug"] == slug }
    rulebook["default_dice"] if rulebook.present?
  end
end
