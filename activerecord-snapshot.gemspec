$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "active_record/snapshot/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activerecord-snapshot"
  s.version     = ActiveRecord::Snapshot::VERSION
  s.authors     = ["Bernardo Farah"]
  s.email       = ["ber@bernardo.me"]
  s.homepage    = "https://github.com/coverhound/active-record-snapshot"
  s.summary     = "Snapshots for ActiveRecord"
  s.description = "Snapshots for ActiveRecord"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "railties", ">= 4.1.0", "< 6.0"
  s.add_dependency "fog-aws", ">= 0.1.2"
  s.add_dependency "hashie", ">= 3.4.3"

  s.add_development_dependency "mocha", "1.1"
  s.add_development_dependency "pry", "~> 0.10.3"
  s.add_development_dependency "simplecov"
end
