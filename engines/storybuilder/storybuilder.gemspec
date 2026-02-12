# frozen_string_literal: false

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "storybuilder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "storybuilder"
  s.version     = Storybuilder::VERSION
  s.authors     = ["Embers Design Studios, LLC"]
  s.email       = ["support@embersds.com"]
  s.homepage    = "http://embersds.com"
  s.summary     = "Storybuilder applications."
  s.description = "Storybuilder applications."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 6.1", "< 8"

  s.add_development_dependency "pg"
end
