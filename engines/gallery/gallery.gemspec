# frozen_string_literal: false

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gallery/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gallery"
  s.version     = Gallery::VERSION
  s.authors     = ["Embers Design Studios, LLC"]
  s.email       = ["support@embersds.com"]
  s.homepage    = "http://embersds.com"
  s.summary     = "Gallery applications."
  s.description = "Gallery applications."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency 'paperclip'
  s.add_dependency 'aws-sdk'#, '~> 1.61.0' # 2 is out but not compatible with paperclip

  s.add_development_dependency "pg"
end
