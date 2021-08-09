$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "toolbox/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "toolbox"
  s.version     = Toolbox::VERSION
  s.authors     = ["Etienne van Delden-de la Haije"]
  s.email       = ["etienne@vandelden.family"]
  s.homepage    = "http://eirvandelden.com"
  s.summary     = "A toolbox for Dungeon Masters."
  s.description = "A collection of tools usefull for dungeon masters to use."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 5.0.7", ">= 5.0.7.2"

  s.add_development_dependency "pg"
end
