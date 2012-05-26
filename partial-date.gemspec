# -*- encoding: utf-8 -*-

require File.expand_path('../lib/partial-date/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "partial-date"
  gem.version       = PartialDate::VERSION
  gem.summary       = "A simple date class that can be used to store partial date values in a single column/attribute." 
  gem.description   = "A simple date class that can be used to store partial date values in a single column/attribute. An example use case would include an archive, or catalogue entry where the complete date is unknown."
  gem.license       = "MIT"
  gem.authors       = ["Anthony Bouch"]
  gem.email         = ["tony@58bits.com"]
  gem.homepage      = "https://github.com/58bits/partial-date#readme"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rubygems-tasks", "~> 0.2"
  gem.add_development_dependency "rspec", "~> 2.4"
  gem.add_development_dependency "yard", "~> 0.7"
end
