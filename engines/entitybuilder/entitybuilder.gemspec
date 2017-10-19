$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "entitybuilder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "entitybuilder"
  s.version     = Entitybuilder::VERSION
  s.authors     = ["Embers Design Studios, LLC"]
  s.email       = ["support@embersds.com"]
  s.homepage    = "http://embersds.com"
  s.summary     = "Entitybuilder applications."
  s.description = "Entitybuilder applications."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"

  s.add_development_dependency "pg"
end
