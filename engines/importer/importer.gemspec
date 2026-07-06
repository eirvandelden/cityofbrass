$:.push File.expand_path("../lib", __FILE__)

require "importer/version"

Gem::Specification.new do |s|
  s.name        = "importer"
  s.version     = Importer::VERSION
  s.authors     = [ "Etienne van Delden de la Haije" ]
  s.email       = [ "etienne@vandelden.family" ]
  s.homepage    = "http://embersds.com"
  s.summary     = "Importer applications."
  s.description = "Importer applications."
  s.license     = "O’Saasy"

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 7.1"
  s.add_dependency "nokogiri"
end
