$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "activeplay/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activeplay"
  s.version     = Activeplay::VERSION
  s.authors     = ["Embers Design Studios, LLC"]
  s.email       = ["support@embersds.com"]
  s.homepage    = "http://embersds.com"
  s.summary     = "Activeplay applications."
  s.description = "Activeplay applications."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"

  s.add_development_dependency "pg"
end
